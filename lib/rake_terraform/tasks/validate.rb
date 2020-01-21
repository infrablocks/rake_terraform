require 'rake_factory'
require 'ruby_terraform'
require 'ostruct'
require 'colored2'

module RakeTerraform
  module Tasks
    class Validate < RakeFactory::Task
      default_name :validate
      default_prerequisites ->(t) { [t.ensure_task_name] }
      default_description ->(t) {
        "Validate #{t.configuration_name} using terraform"
      }

      parameter :configuration_name, :required => true
      parameter :source_directory, :required => true
      parameter :work_directory, :required => true

      parameter :backend_config

      parameter :vars, default: {}
      parameter :var_file
      parameter :state_file

      parameter :debug, :default => false
      parameter :no_color, :default => false

      parameter :ensure_task_name, :default => :'terraform:ensure'

      action do |t|
        Colored2.disable! if t.no_color

        configuration_directory =
            File.join(t.work_directory, t.source_directory)

        puts "Validating #{t.configuration_name}".cyan
        RubyTerraform.clean(
            directory: configuration_directory)

        mkdir_p File.dirname(configuration_directory)
        cp_r t.source_directory, configuration_directory

        Dir.chdir(configuration_directory) do
          RubyTerraform.init(
              backend_config: t.backend_config,
              no_color: t.no_color)
          RubyTerraform.validate(
              no_color: t.no_color,
              state: t.state_file,
              vars: t.vars,
              var_file: t.var_file)
        end
      end
    end
  end
end
