# frozen_string_literal: true

require 'rake_factory'
require 'ruby_terraform'
require 'ostruct'
require 'colored2'

module RakeTerraform
  module Tasks
    class Output < RakeFactory::Task
      default_name :output
      default_prerequisites(RakeFactory::DynamicValue.new do |t|
        [t.ensure_task_name]
      end)
      default_description(RakeFactory::DynamicValue.new do |t|
        "Output #{t.configuration_name} using terraform"
      end)

      parameter :configuration_name, required: true
      parameter :source_directory, required: true
      parameter :work_directory, required: true

      parameter :environment, default: {}

      parameter :backend_config

      parameter :state_file

      parameter :debug, default: false
      parameter :input, default: false
      parameter :no_color, default: false
      parameter :no_print_output, default: false

      parameter :ensure_task_name, default: :'terraform:ensure'

      action do |task|
        Colored2.disable! if task.no_color

        module_directory =
          File.join(FileUtils.pwd, task.source_directory)
        configuration_directory =
          File.join(task.work_directory, task.source_directory)

        Kernel.puts("Output of #{task.configuration_name}".cyan)

        prepare_configuration_directory(configuration_directory)
        init_configuration(configuration_directory, module_directory, task)
        output = output_configuration(configuration_directory, task)

        Kernel.puts(output) unless task.no_print_output

        output
      end

      def prepare_configuration_directory(configuration_directory)
        FileUtils.rm_rf(configuration_directory)
        FileUtils.mkdir_p(configuration_directory)
      end

      def init_configuration(configuration_directory, module_directory, task)
        RubyTerraform.init(
          {
            chdir: configuration_directory,
            from_module: module_directory,
            backend_config: task.backend_config,
            no_color: task.no_color,
            input: task.input
          },
          { environment: task.environment }
        )
      end

      def output_configuration(configuration_directory, task)
        RubyTerraform.output(
          {
            chdir: configuration_directory,
            no_color: task.no_color,
            state: task.state_file
          },
          { environment: task.environment }
        )
      end
    end
  end
end
