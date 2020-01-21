require 'rake_factory'

require_relative '../tasks'

module RakeTerraform
  module TaskSets
    class All < RakeFactory::TaskSet
      parameter :configuration_name, :required => true
      parameter :source_directory, :required => true
      parameter :work_directory, :required => true

      parameter :backend_config

      parameter :vars
      parameter :var_file
      parameter :state_file

      parameter :debug, :default => false

      parameter :no_color, :default => false
      parameter :no_backup, :default => false
      parameter :no_print_output, :default => false

      parameter :backup_file
      parameter :plan_file

      parameter :argument_names

      parameter :ensure_task_name, :default => :'terraform:ensure'

      parameter :validate_task_name, :default => :validate
      parameter :validate_argument_names

      parameter :plan_task_name, :default => :plan
      parameter :plan_argument_names

      parameter :provision_task_name, :default => :provision
      parameter :provision_argument_names

      parameter :destroy_task_name, :default => :destroy
      parameter :destroy_argument_names

      parameter :output_task_name, :default => :output
      parameter :output_argument_names

      task Tasks::Validate,
          name: ->(ts) { ts.validate_task_name },
          argument_names: ->(ts) {
            ts.validate_argument_names || ts.argument_names || []
          }
      task Tasks::Plan, {
          name: ->(ts) { ts.plan_task_name },
          argument_names: ->(ts) {
            ts.plan_argument_names || ts.argument_names || []
          }
      }
      task Tasks::Provision, {
          name: ->(ts) { ts.provision_task_name },
          argument_names: ->(ts) {
            ts.provision_argument_names || ts.argument_names || []
          }
      }
      task Tasks::Destroy, {
          name: ->(ts) { ts.destroy_task_name },
          argument_names: ->(ts) {
            ts.destroy_argument_names || ts.argument_names || []
          }
      }
      task Tasks::Output, {
          name: ->(ts) { ts.output_task_name },
          argument_names: ->(ts) {
            ts.output_argument_names || ts.argument_names || []
          }
      }
    end
  end
end