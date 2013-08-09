# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'p0f_parser/version'

Gem::Specification.new do |gem|
  gem.name          = "p0f_parser"
  gem.version       = P0fParser::VERSION
  gem.authors       = ["Sam Stelfox"]
  gem.email         = ["sstelfox+gems@bedroomprogrammers.net"]
  gem.description   = %q{Parse the log output of the p0f tool into a more easy to consume JSON format.}
  gem.summary       = %q{Parse the log output of the p0f tool into a more easy to consume JSON format.}

  gem.homepage      = "http://stelfox.net/projects/p0f_parser"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "yard"
end
