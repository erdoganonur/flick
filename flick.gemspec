# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flick/version'

Gem::Specification.new do |spec|
  spec.name          = "flick"
  spec.version       = Flick::VERSION
  spec.authors       = ["Justin"]
  spec.email         = ["justin.ison@gmail.com"]

  spec.summary       = %q{A CLI to capture screenshots and video for Android (Devices & Emulators) and iOS (Devices).}
  spec.description   = %q{A Screenshot and Video record too for iOS and Android from command line}
  spec.homepage      = "https://github.com/isonic1/flick"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["flick"]
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_dependency "parallel"
  spec.add_dependency "colorize"
  spec.add_dependency "commander"
  spec.add_dependency "json"
  spec.add_dependency "wannabe_bool"
  spec.add_dependency "awesome_print"
end