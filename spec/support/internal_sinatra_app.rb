require 'sinatra'

module DualDeck
  class InternalSinatraApp < Sinatra::Application
    get '/hi' do
      "Hello"
    end

    get '/remote-hi' do
      uri = URI.parse("http://localhost:#{DualDeck::ExternalSinatraApp.port}/hi")
      Net::HTTP.get(uri)
    end

    post '/yo' do
      "Yo #{params[:name]}"
    end

    get '/secure-random-1' do
      SecureRandom.hex(10)
    end

    get '/secure-random-2' do
      SecureRandom.hex(10)
    end

    get '/secure-random-3' do
      SecureRandom.hex(10)
    end

    get '/first-time' do
      Time.now.to_f.to_s
    end

    get '/second-time' do
      Time.now.to_f.to_s
    end
  end
end
