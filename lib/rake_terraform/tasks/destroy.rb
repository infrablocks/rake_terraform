require 'ruby_terraform'
require 'ostruct'
require 'colored2'
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
      parameter :var_file
      parameter :state_file

      parameter :debug, :default => false
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
          Colored2.disable! if no_color

          puts "Destroying #{configuration_name}".cyan

          params = OpenStruct.new({
              configuration_name: configuration_name,
              source_directory: source_directory,
              work_directory: work_directory,
              backend_config: backend_config,
              var_file: var_file,
              state_file: state_file,
              debug: debug,
              no_color: no_color,
              no_backup: no_backup,
              backup_file: backup_file,
          })

          derived_source_directory = source_directory.respond_to?(:call) ?
             source_directory.call(
                 *[args, params].slice(0, source_directory.arity)) :
             source_directory

          configuration_directory = File.join(work_directory, derived_source_directory)

          RubyTerraform.clean(
              directory: configuration_directory)

          mkdir_p File.dirname(configuration_directory)
          cp_r derived_source_directory, configuration_directory

          params.configuration_directory = configuration_directory

          derived_backend_config = backend_config.respond_to?(:call) ?
              backend_config.call(
                  *[args, params].slice(0, backend_config.arity)) :
              backend_config
          derived_vars = vars.respond_to?(:call) ?
              vars.call(*[args, params].slice(0, vars.arity)) :
              vars
          derived_state_file = state_file.respond_to?(:call) ?
              state_file.call(
                  *[args, params].slice(0, state_file.arity)) :
              state_file

          Dir.chdir(configuration_directory) do
            RubyTerraform.init(
                backend_config: derived_backend_config,
                no_color: no_color)
            RubyTerraform.destroy(
                force: true,
                no_color: no_color,
                no_backup: no_backup,
                backup: backup_file,
                state: derived_state_file,
                vars: derived_vars,
                var_file: var_file)
          end
        end
      end
    end
  end
end
