Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.8.10'

  s.name              = 'tripleloop'
  s.version           = '0.0.1'
  s.date              = '2013-02-22'
  s.rubyforge_project = 'tripleloop'

  s.summary     = "Simple tool for extracting RDF triples from Ruby hashes"
  s.description = s.summary

  s.authors  = ["Andrea Fiore"]
  s.email    = 'andrea.giulio.fiore@googlemail.com'
  s.homepage = 'http://github.com/afiore/tripleloop'

  s.require_paths = %w[lib]
  s.executables = []

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency('rdf')

  s.add_development_dependency('rspec', "~> 2.12.0")
  s.add_development_dependency('fakefs', "~> 0.4.0")
  s.add_development_dependency('pry')

  # = MANIFEST =
  s.files = %w[
    History.txt
    README.md
  ] + (`git ls-files examples lib spec`).split("\n")
  # = MANIFEST =
end
