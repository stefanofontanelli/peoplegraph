# coding: utf-8

Gem::Specification.new do |spec|
  spec.name = 'peoplegraph'
  spec.version = `cat #{File.dirname(__FILE__)}/VERSION`
  spec.authors = ['Stefano Fontanelli']
  spec.email = ['s.fontanelli@gmail.com']
  spec.homepage = 'https://github.com/stefanofontanelli/peoplegraph'
  spec.summary = 'Ruby client for PeopleGraph.io API'
  spec.description = 'A Ruby client for the PeopleGraph.io API'

  spec.files = Dir.glob('lib/**/*') + Dir.glob('bin/*') + %w(VERSION)
  spec.executables = Dir.glob('bin/*').map { |x| x.sub(%r{^bin/}, '') }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.add_dependency 'log4r', '~> 1.1', '>= 1.1.10'
  spec.add_dependency 'faraday', '~> 0.9.1', '>= 0.9.1'
  spec.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.6.2'
  spec.add_dependency 'multi_json', '>= 1.10.1', '~> 1.10.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'mocha', '~> 1.1.0', '>= 1.1.0'
  spec.add_development_dependency 'webmock', '~> 1.22.1', '>= 1.22.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry', '~> 0.10.1'
  spec.add_development_dependency 'rspec', '~> 3.3', '>= 3.3.0'
  spec.add_development_dependency 'minitest', '~> 5.8', '>= 5.8.3'
end
