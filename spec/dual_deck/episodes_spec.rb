require "spec_helper"
require "pry"

describe 'episodes' do
  let(:vcr_cassette_dir) { "#{SPEC_ROOT}/support/fixtures/vcr_cassettes" }
  let(:replay_settings_path) { "#{vcr_cassette_dir}/complex_interaction/replay_settings.yml"}

  context 'loading' do
    before(:each) { DualDeck::Episodes.replay_settings = replay_settings_path }

    it 'returns the full path of replay settings' do
      expect(DualDeck::Episodes.internal_cassette)
        .to be_a(Hash)
    end

    it 'returns an array of episodes' do
      expect(DualDeck::Episodes.load_episodes.count)
        .to eq(5)
    end

    it 'responds to first', skip_vcr_reset: true do
      single_episode = DualDeck::Episodes.load_episodes.first
      expect(single_episode).to be_an(DualDeck::Episode)
      expect(single_episode.request).to be_a(DualDeck::Request)
      expect(single_episode.response).to be_a(DualDeck::Response)
      expect(single_episode.recorded_at).to be_a(DateTime)
    end
  end
end
