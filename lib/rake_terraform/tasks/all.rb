module RakeTerraform
  module Tasks
    class All < TaskLib
      parameter :configuration_name, :required => true
      parameter :configuration_directory, :required => true

      parameter :backend
      parameter :backend_config

      parameter :vars
      parameter :state_file

      parameter :no_color, :default => false
      parameter :no_backup, :default => false

      parameter :backup_file

      parameter :ensure_task, :default => :'terraform:ensure'
      parameter :provision_task_name, :default => :provision
      parameter :destroy_task_name, :default => :destroy

      def define
        Provision.new do |t|
          t.name = provision_task_name

          t.configuration_name = configuration_name
          t.configuration_directory = configuration_directory

          t.backend = backend
          t.backend_config = backend_config

          t.vars = vars
          t.state_file = state_file

          t.no_color = no_color
          t.no_backup = no_backup

          t.backup_file = backup_file

          t.ensure_task = ensure_task
        end
        Destroy.new do |t|
          t.name = destroy_task_name

          t.configuration_name = configuration_name
          t.configuration_directory = configuration_directory

          t.backend = backend
          t.backend_config = backend_config

          t.vars = vars
          t.state_file = state_file

          t.no_color = no_color
          t.no_backup = no_backup

          t.backup_file = backup_file

          t.ensure_task = ensure_task
        end
      end
    end
  end
end