require "dual_deck/internal_interaction"
require "active_support/core_ext/time/calculations"
require "timecop"

module DualDeck
  class RackMiddleware
    def initialize(app, options = {})
      @app = app
      @replay = options[:replay]
      @feature = options[:feature]
      @record = options[:record] || :new_episodes
      @insecure_random = options[:insecure_random] || false
      @time_freeze = options[:time_freeze]

      if @insecure_random
        require "dual_deck/insecure_random"
        @time_freeze ||= Time.now
      end
    end

    def call(env)
      if @feature
        ::VCR.use_cassette("#{@feature}/internal_interactions", record: @record) do
          middlewares { capture_internal_interaction(env) }
        end
      else
        capture_internal_interaction(env)
      end
    end

    def middlewares
      time_freeze_middleware { insecure_middleware { yield } }
    end

    def time_freeze_middleware
      if @time_freeze
        ::Timecop.freeze(@time_freeze.change(usec: 0)) { yield }
      else
        yield
      end
    end

    def insecure_middleware
      if @insecure_random
        InsecureRandom.with_disabled_randomness { yield }
      else
        yield
      end
    end

    def capture_internal_interaction(env)
      req = Rack::Request.new(env)
      transaction = DualDeck::InternalInteraction.new(req)

      if @replay && transaction.can_replay?
        transaction.replay
      else
        status, headers, body = capture_external_interactions { @app.call(env) }
        res = Rack::Response.new(body, status, headers)
        transaction.capture(res)
        [status, headers, body]
      end
    end

    def capture_external_interactions
      VCR.use_cassette("#{@feature}/external_interactions", record: @record) do
        yield
      end
    end
  end
end
