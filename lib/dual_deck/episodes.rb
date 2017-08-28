require 'dual_deck/episode'
require 'yaml'

module DualDeck
  class Episodes
    include Enumerable

    def initialize(members = [])
      @members = members
    end

    def each(&block)
      @members.each(&:block)
    end

    def self.full_settings_path(replay_settings_path)
      settings = YAML.load(File.read(replay_settings_path))[:replay_settings]
      internal_cassette = [settings[:vcr_cassette_path], settings[:internal_cassette]].join('/') + '.yml'
      internal_cassette_full_path = File.expand_path(internal_cassette)
      @full_settings_path ||= internal_cassette_full_path if File.exist?(internal_cassette_full_path)
    end

    def self.load_episodes(replay_settings_path)
      if full_settings_path(replay_settings_path)
        YAML.load(File.read(@full_settings_path))['http_interactions'].map do |interaction|
          req = interaction['request']
          req['uri'] = URI.parse(req['uri'])
          req['body'] = req['body']['string']
          req['headers'] = Hash[req['headers'].map { |k, v| [k, v.first] }]
          res = interaction['response']
          res['status'] = res['status']['code']
          res['headers'] = Hash[res['headers'].map { |k, v| [k, v.first] }]
          res['body'] = res['body']['string']
          recorded_at = Time.parse(interaction['recorded_at'].to_s).to_datetime
          Episode.new(req, res, recorded_at)
        end
      end
    end
  end
end
