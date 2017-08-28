require 'sinatra'
require 'support/localhost_server'

module DualDeck
  class ExternalSinatraApp < ::Sinatra::Base
    disable :protection

    get '/hi' do
      "Hello from remote!"
    end

    @_boot_failed = false

    class << self
      def port
        server.port
      end

      def server
        raise "Sinatra app failed to boot." if @_boot_failed
        @server ||= begin
          DualDeck::LocalhostServer.new(new)
        rescue
          @_boot_failed = true
          raise
        end
      end

      alias boot server
    end
  end
end
