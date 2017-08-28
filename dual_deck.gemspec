# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dual_deck/version'

Gem::Specification.new do |spec|
  spec.name          = "dual_deck"
  spec.version       = DualDeck::VERSION
  spec.authors       = ["Kam Karshenas"]
  spec.email         = ["kam@saneshark.com"]

  spec.summary       = %q{Record inbound rack request responses, while recording outbound HTTP interactions and replaying them during future test runs.}
  spec.description   = spec.summary
  spec.homepage      = "http://github.com/saneshark/dual_deck"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "vcr", ">= 2.9"
  spec.add_dependency "vcr_cable"
  spec.add_dependency "timecop"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "sinatra"
end
