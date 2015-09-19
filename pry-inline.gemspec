# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pry-inline/version'

Gem::Specification.new do |spec|
  spec.name          = 'pry-inline'
  spec.version       = PryInline::VERSION
  spec.authors       = ['Seiichi KONDO']
  spec.email         = ['seikichi@kmc.gr.jp']

  spec.summary       = 'Inline variables view like RubyMine'
  spec.description   = 'This Pry plugin enables inline variables view like RubyMine!'
  spec.homepage      = 'https://github.com/seikichi/pry-inline'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'pry', '~> 0.10.0'
  spec.add_dependency 'unicode', '~> 0.4.4'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'simplecov', '~> 0.10.0'
  spec.add_development_dependency 'test-unit', '>= 3.0.0'
end
