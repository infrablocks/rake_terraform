require 'ruby_terraform'
require 'ostruct'
require_relative '../tasklib'

module RakeTerraform
  module Tasks
    class Plan < TaskLib
      parameter :name, :default => :plan
      parameter :argument_names, :default => []

      parameter :configuration_name, :required => true
      parameter :source_directory, :required => true
      parameter :work_directory, :required => true

      parameter :backend_config

      parameter :vars, default: {}
      parameter :state_file

      parameter :no_color, :default => false

      parameter :plan_file
      parameter :destroy, :default => false

      parameter :ensure_task, :default => :'terraform:ensure'

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        desc "Plan #{configuration_name} using terraform"
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
          derived_backend_config = backend_config.respond_to?(:call) ?
              backend_config.call(
                  *[args, params].slice(0, backend_config.arity)) :
              backend_config

          puts "Planning #{configuration_name}"

          RubyTerraform.clean(
              directory: configuration_directory)

          cp_r source_directory, configuration_directory

          Dir.chdir(configuration_directory) do
            RubyTerraform.init(
                path: configuration_directory,
                backend_config: derived_backend_config,
                no_color: no_color)
            RubyTerraform.plan(
                no_color: no_color,
                destroy: destroy,
                state: state_file,
                plan: plan_file,
                vars: derived_vars)
          end
        end
      end
    end
  end
end