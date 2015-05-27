Gem::Specification.new do |s|
  s.name = 'peoplegraph'
  s.version = `cat #{File.dirname(__FILE__)}/VERSION`
  s.authors = ['Stefano Fontanelli']
  s.email = ['s.fontanelli@gmail.com']
  s.homepage = 'https://github.com/stefanofontanelli/peoplegraph'
  s.summary = 'Ruby client for PeopleGraph.io API'
  s.description = 'A Ruby client for the PeopleGraph.io API'
  s.files = `git ls-files | grep lib`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{|i| i.gsub(/^bin\//,'')}
  s.add_dependency 'faraday', '~> 0.9.1', '>= 0.9.1'
  s.add_dependency 'multi_json', '~> 1.11.0', '>= 1.11.0'
  s.add_development_dependency 'rake'
end
