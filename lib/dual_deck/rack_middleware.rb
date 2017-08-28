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
      @time_freeze = options[:time_freeze].try(:change, usec: 0)

      if @insecure_random
        require "dual_deck/insecure_random"
        @time_freeze ||= Time.now.change(usec: 0)
      end
      record_feature_settings unless File.exist?(feature_path)
    end

    def record_feature_settings
      directory = File.dirname(feature_path)
      FileUtils.mkdir_p(directory) unless File.exist?(directory)
      File.binwrite(feature_path, { replay_settings: feature_settings }.to_yaml )
    end

    def feature_path
      VCR.configuration.cassette_library_dir + "/#{@feature}/replay_settings.yml"
    end

    def feature_settings
      {
        vcr_cassette_path: relative_cassette_path,
        internal_cassette: internal_cassette,
        external_cassette: external_cassette,
        insecure_random: @insecure_random,
        time_freeze: @time_freeze
      }
    end

    def relative_cassette_path
      VCR.configuration.cassette_library_dir.split(Dir.pwd.to_s)[1].sub('/', '')
    end

    def internal_cassette
      "#{@feature}/internal_interactions"
    end

    def external_cassette
      "#{@feature}/external_interactions"
    end

    def call(env)
      if @feature
        ::VCR.use_cassette(feature_settings[:internal_cassette], record: @record) do
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
        ::Timecop.freeze(@time_freeze) { yield }
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
      VCR.use_cassette(feature_settings[:external_cassette], record: @record) do
        yield
      end
    end
  end
end
