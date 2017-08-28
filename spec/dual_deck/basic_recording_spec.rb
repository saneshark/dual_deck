require "spec_helper"
require "sinatra"
require "rack/test"
require "webmock"
require "net/http"
require "pry"

describe 'basic dual deck recording' do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new do
      use DualDeck::RackMiddleware, replay: true, feature: "feature_under_test"
      run DualDeck::InternalSinatraApp
    end
  end

  let(:feature_name) { "feature_under_test" }
  let(:internal_cassette) { VCR::Cassette.new("#{feature_name}/internal_interactions") }
  let(:external_cassette) { VCR::Cassette.new("#{feature_name}/external_interactions") }

  context 'internal requests' do
    it 'runs the HTTP request' do
      get '/hi'
      expect(last_response.body).to eq('Hello')
      post '/yo', name: "John"

      expect(internal_cassette.http_interactions.interactions.count).to be(2)
      expect(external_cassette.http_interactions.interactions.count).to be(0)
    end

    it 'replays the cassette' do
      get '/hi'
      get '/hi'

      expect(internal_cassette.http_interactions.interactions.count).to be(1)
      expect(external_cassette.http_interactions.interactions.count).to be(0)
    end

    it 'doesnt freeze the time' do
      get '/first-time'
      first_response = last_response
      get '/second-time'
      second_response = last_response
      get '/first-time'

      expect(first_response.body).not_to eq(second_response.body)
      expect(first_response.body).to eq(last_response.body)
    end

    it 'never returns the same random bytes' do
      get '/secure-random-1'
      first_response = last_response
      get '/secure-random-2'
      second_response = last_response
      get '/secure-random-3'

      expect(first_response.body).not_to eq(second_response.body)
      expect(second_response.body).not_to eq(last_response.body)
      expect(first_response.body).not_to eq(last_response.body)
    end
  end

  context 'internal requests with external requests, replaying both requests' do
    it 'runs the HTTP request' do
      get '/remote-hi'
      get '/remote-hi'

      expect(last_response.body).to eq('Hello from remote!')
      expect(internal_cassette.http_interactions.interactions.count).to be(1)
      expect(external_cassette.http_interactions.interactions.count).to be(1)
    end
  end
end
