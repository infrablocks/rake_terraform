# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_terraform/version'

files = %w[
  bin
  lib
  CODE_OF_CONDUCT.md
  rake_terraform.gemspec
  Gemfile
  LICENSE.txt
  Rakefile
  README.md
]

Gem::Specification.new do |spec|
  spec.name = 'rake_terraform'
  spec.version = RakeTerraform::VERSION
  spec.authors = ['InfraBlocks Maintainers']
  spec.email = ['maintainers@infrablocks.io']

  spec.summary = 'Rake tasks for running terraform.'
  spec.description =
    'Provides rake tasks for executing terraform commands as part of a ' \
    'rake build.'
  spec.homepage = 'https://github.com/infrablocks/rake_terraform'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(/^(#{files.map { |g| Regexp.escape(g) }.join('|')})/)
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'colored2', '~> 3.1'
  spec.add_dependency 'rake_dependencies', '~> 2.11'
  spec.add_dependency 'rake_factory', '~> 0.23'
  spec.add_dependency 'ruby-terraform', '~> 1.1'

  spec.add_development_dependency 'activesupport', '~> 5.2'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'fakefs', '~> 0.18'
  spec.add_development_dependency 'gem-release', '~> 2.1'
  spec.add_development_dependency 'guard', '~> 2.16'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rake_circle_ci', '~> 0.9'
  spec.add_development_dependency 'rake_github', '~> 0.5'
  spec.add_development_dependency 'rake_gpg', '~> 0.12'
  spec.add_development_dependency 'rake_ssh', '~> 0.4'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 1.12'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'yard', '~> 0.9'
end
