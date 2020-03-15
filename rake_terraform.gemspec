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
  spec.homepage = 'https://github.com/infrablocks/rake_terraform'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'rake_dependencies', '~> 2', '< 3'
  spec.add_dependency 'rake_factory', '>= 0.23', '< 1'
  spec.add_dependency 'ruby-terraform', '~> 0.48'
  spec.add_dependency 'colored2', '~> 3.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rake_circle_ci', '~> 0.3'
  spec.add_development_dependency 'rake_github', '~> 0.3'
  spec.add_development_dependency 'rake_ssh', '~> 0.2'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'gem-release', '~> 2.0'
  spec.add_development_dependency 'activesupport', '~> 5.2'
  spec.add_development_dependency 'fakefs', '~> 0.18'
end
