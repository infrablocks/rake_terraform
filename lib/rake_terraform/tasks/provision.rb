require 'ruby_terraform'
require 'ostruct'
require_relative '../tasklib'

module RakeTerraform
  module Tasks
    class Provision < TaskLib
      parameter :name, :default => :provision
      parameter :argument_names, :default => []

      parameter :configuration_name, :required => true
      parameter :configuration_directory, :required => true

      parameter :backend
      parameter :backend_config

      parameter :vars, default: {}
      parameter :state_file

      parameter :no_color, :default => false
      parameter :no_backup, :default => false

      parameter :backup_file

      parameter :ensure_task, :default => :'terraform:ensure'

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        if backend && state_file
          raise ArgumentError.new(
              "Only one of 'state_file' and 'backend' can be provided.")
        end

        desc "Provision #{configuration_name} using terraform"
        task name, argument_names => [ensure_task] do |_, args|
          params = OpenStruct.new({
              configuration_name: configuration_name,
              configuration_directory: configuration_directory,
              backend: backend,
              backend_config: backend_config,
              state_file: state_file,
              no_color: no_color,
              no_backup: no_backup,
              backup_file: backup_file
          })

          derived_vars = vars.respond_to?(:call) ?
            vars.call(*[args, params].slice(0, vars.arity)) :
            vars
          derived_backend_config = backend_config.respond_to?(:call) ?
            backend_config.call(
                *[args, params].slice(0, backend_config.arity)) :
            backend_config

          puts "Provisioning #{configuration_name}"

          RubyTerraform.clean
          RubyTerraform.get(
              directory: configuration_directory,
              no_color: no_color)
          if backend
            RubyTerraform.remote_config(
                no_color: no_color,
                backend: backend,
                backend_config: derived_backend_config)
          end
          RubyTerraform.apply(
              no_color: no_color,
              no_backup: no_backup,
              backup: backup_file,
              directory: configuration_directory,
              state: state_file,
              vars: derived_vars)
        end
      end
    end
  end
end