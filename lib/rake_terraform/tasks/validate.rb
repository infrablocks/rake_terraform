require 'ruby_terraform'
require 'ostruct'
require_relative '../tasklib'

module RakeTerraform
  module Tasks
    class Validate < TaskLib
      parameter :name, :default => :validate
      parameter :argument_names, :default => []

      parameter :configuration_name, :required => true
      parameter :source_directory, :required => true
      parameter :work_directory, :required => true

      parameter :backend_config

      parameter :vars, default: {}
      parameter :state_file

      parameter :no_color, :default => false

      parameter :ensure_task, :default => :'terraform:ensure'

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        desc "Validate #{configuration_name} using terraform"
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
          })

          derived_vars = vars.respond_to?(:call) ?
              vars.call(*[args, params].slice(0, vars.arity)) :
              vars
          derived_state_file = state_file.respond_to?(:call) ?
              state_file.call(
                  *[args, params].slice(0, state_file.arity)) :
              state_file

          puts "Validating #{configuration_name}"

          RubyTerraform.clean(
              directory: configuration_directory)

          mkdir_p File.dirname(configuration_directory)
          cp_r source_directory, configuration_directory

          var_file = File.join(configuration_directory, "terraform.tfvars")
          File.open(var_file, 'w') do |file|
            derived_vars.each{ |k, v| file.write("#{k} = \"#{v}\"\n") }
          end

          Dir.chdir(configuration_directory) do
            RubyTerraform.validate(
                no_color: no_color,
                state: derived_state_file,
                var_file: "terraform.tfvars")
          end
        end
      end
    end
  end
end