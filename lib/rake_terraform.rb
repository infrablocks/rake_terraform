# frozen_string_literal: true

require 'logger'
require 'rake_dependencies'
require 'ruby_terraform'
require 'rake_terraform/version'
require 'rake_terraform/tasks'
require 'rake_terraform/task_sets'

module RakeTerraform
  def self.define_command_tasks(opts = {}, &)
    RakeTerraform::TaskSets::All.define(opts, &)
  end

  def self.define_installation_tasks(opts = {})
    command_task_set = define_command_installation_tasks(opts)
    provider_task_sets = define_providers_installation_tasks(opts)

    configure_ruby_terraform(command_task_set.binary)
    wire_provider_ensure_tasks(opts)

    [command_task_set.delegate, provider_task_sets.map(&:delegate)]
  end

  class << self
    private

    def define_command_installation_tasks(opts = {})
      RakeTerraform::TaskSets::Terraform.define(opts)
    end

    def define_provider_installation_tasks(opts = {})
      RakeTerraform::TaskSets::Provider.define(opts)
    end

    def define_providers_installation_tasks(opts = {})
      namespace = opts[:namespace] || :terraform
      providers = opts[:providers] || []

      providers.map do |provider_opts|
        define_provider_installation_tasks(
          { parent_namespace: namespace }.merge(provider_opts)
        )
      end
    end

    def configure_ruby_terraform(binary)
      RubyTerraform.configure { |c| c.binary = binary }
    end

    def wire_provider_ensure_tasks(opts)
      namespace = opts[:namespace] || :terraform
      providers = opts[:providers] || []

      Rake::Task["#{namespace}:ensure"]
        .enhance(providers.map do |provider_opts|
          "#{namespace}:providers:#{provider_opts[:name]}:ensure"
        end)
    end
  end
end
