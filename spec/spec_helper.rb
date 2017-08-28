require "bundler/setup"
require "dual_deck"
require "support/external_sinatra_app"
require "support/internal_sinatra_app"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  tmp_dir = File.expand_path('../../tmp/vcr_cassettes', __FILE__)

  config.before(:each) do |example|
    return if example.metadata[:skip_vcr_reset]
    VCR.configure do |config|
      config.cassette_library_dir = "tmp/vcr_cassettes"
      config.hook_into :webmock
    end
  end

  config.after(:each) do |example|
    return if example.metadata[:skip_cleanup]
    FileUtils.rm_rf tmp_dir
  end
end

DualDeck::ExternalSinatraApp.boot
