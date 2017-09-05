require 'ruby_terraform'
require_relative '../tasklib'

module RakeTerraform
  module Tasks
    class Destroy < TaskLib
      parameter :name, :default => :destroy
      parameter :argument_names, :default => []

      parameter :configuration_name, :required => true
      parameter :source_directory, :required => true
      parameter :work_directory, :required => true

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
        desc "Destroy #{configuration_name} using terraform"
        task name, argument_names => [ensure_task] do |_, args|
          configuration_directory = File.join(work_directory, source_directory)

          params = OpenStruct.new({
              configuration_name: configuration_name,
              source_directory: source_directory,
              work_directory: work_directory,
              configuration_directory: configuration_directory,
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

          puts "Destroying #{configuration_name}"

          RubyTerraform.clean(
              directory: configuration_directory)

          mkdir_p configuration_directory
          cp_r source_directory, configuration_directory

          Dir.chdir(configuration_directory) do
            RubyTerraform.init(
                backend_config: derived_backend_config,
                no_color: no_color)
            RubyTerraform.destroy(
                force: true,
                no_color: no_color,
                no_backup: no_backup,
                backup: backup_file,
                state: state_file,
                vars: derived_vars)
          end
        end
      end
    end
  end
end