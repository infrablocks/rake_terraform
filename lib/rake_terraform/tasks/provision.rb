require 'ruby_terraform'
require_relative '../tasklib'

module RakeTerraform
  module Tasks
    class Provision < TaskLib
      parameter :name, :default => :provision

      parameter :configuration_name, :required => true
      parameter :configuration_directory, :required => true

      parameter :backend
      parameter :backend_config

      parameter :vars, default: {}

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        desc "Provision #{configuration_name} using terraform"
        task name do
          apply_vars = vars.respond_to?(:call) ?
            vars.call(
                configuration_name: configuration_name,
                configuration_directory: configuration_directory,
                backend: backend,
                backend_config: backend_config) :
            vars

          RubyTerraform.clean
          RubyTerraform.get(
              directory: configuration_directory)
          if backend
            RubyTerraform.remote_config(
                backend: backend,
                backend_config: backend_config)
          end
          RubyTerraform.apply(
              directory: configuration_directory,
              vars: apply_vars)
        end
      end
    end
  end
end