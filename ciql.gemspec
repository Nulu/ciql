# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)

require 'ciql/version'

Gem::Specification.new do |s|
  s.name          = 'ciql'
  s.version       = Ciql::VERSION.dup
  s.authors       = ['Justin Bradford']
  s.email         = ['justin@nulu.com']
  s.homepage      = 'https://github.com/nulu/ciql'
  s.summary       = %q{CQL Cassandra client for Ruby}
  s.description   = %q{A CQL-based Cassandra client for Ruby}
  s.license       = 'Apache'

  s.files         = Dir['lib/**/*.rb', 'README.md']
  s.test_files    = Dir['spec/**/*.rb']
  s.require_paths = %w(lib)

  s.add_dependency('cql-rb', '~> 1.0.0.pre3')
  s.add_dependency('simple_uuid', '~> 0.3.0')

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
end
