# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_terraform/version'

Gem::Specification.new do |spec|
  spec.name = 'rake_terraform'
  spec.version = RakeTerraform::VERSION
  spec.authors = ['Toby Clemson']
  spec.email = ['tobyclemson@gmail.com']

  spec.summary = 'Rake tasks for running terraform.'
  spec.description = 'Provides rake tasks for executing terraform commands as part of a rake build.'
  spec.homepage = 'https://github.com/tobyclemson/rake_terraform'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rake_dependencies', '~> 0.15'
  spec.add_dependency 'ruby-terraform', '~> 0.9'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'gem-release', '~> 0.7'
  spec.add_development_dependency 'activesupport', '~> 4.2'
  spec.add_development_dependency 'fakefs', '~> 0.10'
end
