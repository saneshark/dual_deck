require 'dual_deck/episode'
require 'yaml'

module DualDeck
  class Episodes
    include Enumerable

    attr_reader :replay_settings

    def initialize(members, replay_settings)
      @members = members
      @replay_settings = replay_settings
    end

    def each(&block)
      @members.each do |member|
        block.call(member)
      end
    end

    def self.internal_cassette
      @internal_cassette ||= begin
        internal_cassette = [replay_settings[:vcr_cassette_path], replay_settings[:internal_cassette]].join('/') + '.yml'
        internal_cassette_full_path = File.expand_path(internal_cassette)
        YAML.load(File.read(internal_cassette_full_path)) if File.exist?(internal_cassette_full_path)
      end
    end

    def self.load_episodes
      episodes = internal_cassette['http_interactions'].map do |interaction|
        Episode.new(interaction)
      end

      new(episodes, self.replay_settings)
    end

    def self.replay_settings=(file_path)
      @replay_settings = YAML.load(File.read(file_path))[:replay_settings]
    end

    def self.replay_settings
      @replay_settings
    end
  end
end
