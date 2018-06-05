# coding: utf-8
lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'statesman-sequel/version'

Gem::Specification.new do |spec|
  spec.name          = "statesman-sequel"
  spec.version       = StatesmanSequel::VERSION
  spec.authors       = ["Amadeus Folego"]
  spec.email         = ["amadeusfolego@gmail.com"]

  spec.summary       = %q{Statesman adapter and plugin for Sequel}
  spec.description   = %q{Statesman adapter and plugin for Sequel}
  spec.homepage      = "https://github.com/badosu/statesman-sequel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sequel", ">= 4", "< 6"
  spec.add_dependency "statesman", ">= 3.4", "< 4"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "minitest-hooks"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rb-readline"
end
