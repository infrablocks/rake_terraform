require 'spec_helper'

describe RakeTerraform::Tasks::All do
  include_context :rake

  it 'adds all command tasks in the namespace in which it is defined' do
    namespace :network do
      define_tasks
    end

    expect(Rake::Task['network:provision']).not_to be_nil
    expect(Rake::Task['network:destroy']).not_to be_nil
  end

  context 'provision task' do
    it 'configures with the provided configuration name and directory' do
      configuration_name = 'network'
      configuration_directory = 'infra/network'

      provision_configurer = stubbed_provision_configurer

      expect(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:configuration_name=).with(configuration_name))
      expect(provision_configurer)
          .to(receive(:configuration_directory=).with(configuration_directory))

      namespace :network do
        define_tasks do |t|
          t.configuration_name = configuration_name
          t.configuration_directory = configuration_directory
        end
      end
    end

    it 'passes backend configuration when present' do
      backend = 's3'
      backend_config = {
          bucket: 'some-bucket'
      }

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:backend=).with(backend))
      expect(provision_configurer)
          .to(receive(:backend_config=).with(backend_config))

      namespace :network do
        define_tasks do |t|
          t.backend = backend
          t.backend_config = backend_config
        end
      end
    end

    it 'passes nil for backend when no backend configuration present' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:backend=).with(nil))
      expect(provision_configurer)
          .to(receive(:backend_config=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes vars when present' do
      vars = {
          vpc_id: '1234',
          domain_name: 'example.com'
      }

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:vars=).with(vars))

      namespace :network do
        define_tasks do |t|
          t.vars = vars
        end
      end
    end

    it 'passes nil for vars when no vars present' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:vars=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:state_file=).with(state_file))

      namespace :network do
        define_tasks do |t|
          t.state_file = state_file
        end
      end
    end

    it 'passes nil for state file when no state file present' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:state_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:no_color=).with(no_color))

      namespace :network do
        define_tasks do |t|
          t.no_color = no_color
        end
      end
    end

    it 'passes false for no_color by default' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:no_color=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_backup when provided' do
      no_backup = true

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:no_backup=).with(no_backup))

      namespace :network do
        define_tasks do |t|
          t.no_backup = no_backup
        end
      end
    end

    it 'passes false for no_color by default' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:no_color=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes provided backup file when present' do
      backup_file = 'infra/terraform.tfstate.backup'

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:backup_file=).with(backup_file))

      namespace :network do
        define_tasks do |t|
          t.backup_file = backup_file
        end
      end
    end

    it 'passes nil for backup file when no backup file present' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:backup_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes provided ensure task when present' do
      ensure_task = :'tooling:terraform:ensure'

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:ensure_task=).with(ensure_task))

      namespace :network do
        define_tasks do |t|
          t.ensure_task = ensure_task
        end
      end
    end

    it 'passes terraform:ensure for ensure task by default' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:ensure_task=).with(:'terraform:ensure'))

      namespace :network do
        define_tasks
      end
    end

    it 'uses a name of provision by default' do
      provision_configurer = stubbed_provision_configurer

      expect(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:name=).with(:provision))

      define_tasks
    end

    it 'uses the provided name when supplied' do
      provision_configurer = stubbed_provision_configurer

      expect(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:name=).with(:deploy))

      define_tasks do |t|
        t.provision_task_name = :deploy
      end
    end
  end

  context 'destroy task' do
    it 'configures with the provided configuration name and directory' do
      configuration_name = 'network'
      configuration_directory = 'infra/network'

      destroy_configurer = stubbed_destroy_configurer

      expect(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:configuration_name=).with(configuration_name))
      expect(destroy_configurer)
          .to(receive(:configuration_directory=).with(configuration_directory))

      namespace :network do
        define_tasks do |t|
          t.configuration_name = configuration_name
          t.configuration_directory = configuration_directory
        end
      end
    end

    it 'passes backend configuration when present' do
      backend = 's3'
      backend_config = {
          bucket: 'some-bucket'
      }

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:backend=).with(backend))
      expect(destroy_configurer)
          .to(receive(:backend_config=).with(backend_config))

      namespace :network do
        define_tasks do |t|
          t.backend = backend
          t.backend_config = backend_config
        end
      end
    end

    it 'passes nil for backend when no backend configuration present' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:backend=).with(nil))
      expect(destroy_configurer)
          .to(receive(:backend_config=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes vars when present' do
      vars = {
          vpc_id: '1234',
          domain_name: 'example.com'
      }

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:vars=).with(vars))

      namespace :network do
        define_tasks do |t|
          t.vars = vars
        end
      end
    end

    it 'passes nil for vars when no vars present' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:vars=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:state_file=).with(state_file))

      namespace :network do
        define_tasks do |t|
          t.state_file = state_file
        end
      end
    end

    it 'passes nil for state file when no state file present' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:state_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:no_color=).with(no_color))

      namespace :network do
        define_tasks do |t|
          t.no_color = no_color
        end
      end
    end

    it 'passes false for no_color by default' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:no_color=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_backup when provided' do
      no_backup = true

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:no_backup=).with(no_backup))

      namespace :network do
        define_tasks do |t|
          t.no_backup = no_backup
        end
      end
    end

    it 'passes false for no_color by default' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:no_color=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes provided backup file when present' do
      backup_file = 'infra/terraform.tfstate.backup'

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:backup_file=).with(backup_file))

      namespace :network do
        define_tasks do |t|
          t.backup_file = backup_file
        end
      end
    end

    it 'passes nil for backup file when no backup file present' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:backup_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes provided ensure task when present' do
      ensure_task = :'tooling:terraform:ensure'

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:ensure_task=).with(ensure_task))

      namespace :network do
        define_tasks do |t|
          t.ensure_task = ensure_task
        end
      end
    end

    it 'passes terraform:ensure for ensure task by default' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:ensure_task=).with(:'terraform:ensure'))

      namespace :network do
        define_tasks
      end
    end

    it 'uses a name of destroy by default' do
      destroy_configurer = stubbed_destroy_configurer

      expect(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:name=).with(:destroy))

      define_tasks
    end

    it 'uses the provided name when supplied' do
      destroy_configurer = stubbed_destroy_configurer

      expect(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:name=).with(:deploy))

      define_tasks do |t|
        t.destroy_task_name = :deploy
      end
    end
  end

  def define_tasks(&block)
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'

      block.call(t) if block
    end
  end

  def double_allowing(*messages)
    instance = double
    messages.each do |message|
      allow(instance).to(receive(message))
    end
    instance
  end

  def stubbed_provision_configurer
    double_allowing(
        :name=, :backend=, :backend_config=,
        :configuration_name=, :configuration_directory=,
        :vars=, :state_file=,
        :no_color=, :no_backup=, :backup_file=,
        :ensure_task=)
  end

  def stubbed_destroy_configurer
    double_allowing(
        :name=, :backend=, :backend_config=,
        :configuration_name=, :configuration_directory=,
        :vars=, :state_file=,
        :no_color=, :no_backup=, :backup_file=,
        :ensure_task=)
  end
end
