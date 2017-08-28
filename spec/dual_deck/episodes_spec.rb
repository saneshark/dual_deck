require "spec_helper"
require "pry"

describe 'episodes' do
  let(:vcr_cassette_dir) { "#{SPEC_ROOT}/support/fixtures/vcr_cassettes" }
  let(:replay_settings_path) { "#{vcr_cassette_dir}/complex_interaction/replay_settings.yml"}

  context 'loading' do
    it 'returns the full path of replay settings' do
      expect(DualDeck::Episodes.full_settings_path(replay_settings_path))
        .to eq("#{vcr_cassette_dir}/complex_interaction/internal_interactions.yml")
    end

    it 'returns an array of episodes' do
      expect(DualDeck::Episodes.load_episodes(replay_settings_path).size)
        .to eq(5)
    end

    it 'responds to first' do
      single_episode = DualDeck::Episodes.load_episodes(replay_settings_path).first
      expect(single_episode).to be_an(DualDeck::Episode)
      expect(single_episode.request).to be_a(DualDeck::Request)
      expect(single_episode.response).to be_a(DualDeck::Response)
      expect(single_episode.recorded_at).to be_a(DateTime)
    end

    it 'responsds to settings' do
      
    end
  end
end
