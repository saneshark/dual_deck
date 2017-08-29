require "bundler/setup"
require "dual_deck"
require "support/external_sinatra_app"
require "support/internal_sinatra_app"

SPEC_ROOT = File.dirname(File.expand_path('.', __FILE__))

RSpec.shared_context 'Global helpers' do
  let(:vcr_cassette_dir) { "tmp/vcr_cassettes" }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  tmp_dir = File.expand_path('../../tmp/vcr_cassettes', __FILE__)

  config.include_context 'Global helpers'

  config.before(:each) do |example|
    unless example.metadata[:skip_vcr_reset]
      VCR.configure do |config|
        config.cassette_library_dir = vcr_cassette_dir
        config.hook_into :webmock
      end
    end
  end

  config.after(:each) do |example|
    unless example.metadata[:skip_cleanup]
      FileUtils.rm_rf tmp_dir
    end
  end
end

DualDeck::ExternalSinatraApp.boot
