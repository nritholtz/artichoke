# -*- encoding: utf-8 -*-
$: << File.expand_path('../lib', __FILE__)
require 'artichoke/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Nathaniel Ritholtz"]
  gem.email         = ["nritholtz@gmail.com"]
  gem.description   = %q{A library for gmail integration within testing suites, best used in conjuction with integration test tools such as RSpec, Capybara, and/or Cucumber.}
  gem.summary       = %q{A library for gmail integration within testing suites.}
  gem.homepage      = "https://github.com/nritholtz/artichoke"

  gem.files         = `git ls-files`.split($\)
  gem.name          = "artichoke"
  gem.require_paths = ["lib"]
  gem.version       = Artichoke::VERSION

  gem.add_runtime_dependency 'ruby-gmail-nritholtz', '~> 0.3.3'
  gem.add_runtime_dependency 'activesupport', '>= 3.1'
end
