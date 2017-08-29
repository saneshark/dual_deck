require "spec_helper"
require "rack/test"
require "pry"

describe 'episodes' do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new do
      run DualDeck::InternalSinatraApp
    end
  end

  let(:vcr_cassette_dir) { "#{SPEC_ROOT}/support/fixtures/vcr_cassettes" }
  let(:replay_settings_path) { "#{vcr_cassette_dir}/complex_interaction/replay_settings.yml"}

  let(:episodes) do
    DualDeck::Episodes.replay_settings = replay_settings_path
    DualDeck::Episodes.load_episodes
  end

  context 'without correct time or randomness settings' do
    subject do
      results = []
      VCR.use_cassette(episodes.replay_settings[:external_cassette], record: :none) do
        episodes.map do |episode, index|
          make_request(episode)
          results << [episode.test_name, last_response.body == episode.response.body]
        end
      end
      results
    end

    it "should have second result be true" do
      expect(subject[1].last).to be_truthy
    end

    it 'should be false for all the rest' do
      expect((subject - [subject[1]]).map(&:last)).to all(be_falsey)
    end
  end

  context 'without correct randomness settings' do
    subject do
      results = []
      VCR.use_cassette(episodes.replay_settings[:external_cassette], record: :none) do
        episodes.map do |episode, index|
          Timecop.freeze(episode.recorded_at) do
            make_request(episode)
          end
          results << [episode.test_name, last_response.body == episode.response.body]
        end
      end
      results
    end

    it 'should match some interactions' do
      expect(subject.map(&:last)).to eq([true, true, false, false, true])
    end
  end

  context 'with randomess set correctly' do
    before(:each) do
      env = double('env', development?: true, production?: false)
      rails = double('Rails', env: env)
      stub_const("Rails", rails)
      require "dual_deck/insecure_random"
    end

    context 'without correct time' do
      subject do
        results = []
        VCR.use_cassette(episodes.replay_settings[:external_cassette], record: :none) do
          episodes.map do |episode, index|
            InsecureRandom.with_disabled_randomness do
              make_request(episode)
            end
            results << [episode.test_name, last_response.body == episode.response.body]
          end
        end
        results
      end

      it 'should match some interactions' do
        expect(subject.map(&:last)).to eq([false, true, false, false, false])
      end
    end

    context 'with correct time' do
      subject do
        results = []
        VCR.use_cassette(episodes.replay_settings[:external_cassette], record: :none) do
          episodes.map do |episode, index|
            InsecureRandom.with_disabled_randomness do
              Timecop.freeze(episode.recorded_at) do
                make_request(episode)
              end
            end
            results << [episode.test_name, last_response.body == episode.response.body]
          end
        end
        results
      end

      it 'should match all interactions' do
        expect(subject.map(&:last)).to eq([true, true, true, true, true])
      end
    end
  end

  def make_request(episode)
    params = if episode.request.method == 'post'
               Rack::Utils.parse_nested_query(episode.request.body)
             else
               Rack::Utils.parse_nested_query(episode.request.uri.query)
             end
    send(episode.request.method, episode.request.uri.path, params, episode.request.headers)
  end
end
