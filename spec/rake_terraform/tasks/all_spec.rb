require 'spec_helper'

describe RakeTerraform::Tasks::All do
  include_context :rake

  it 'adds all command tasks in the namespace in which it is defined' do
    namespace :network do
      define_tasks
    end

    expect(Rake::Task['network:validate']).not_to be_nil
    expect(Rake::Task['network:plan']).not_to be_nil
    expect(Rake::Task['network:provision']).not_to be_nil
    expect(Rake::Task['network:destroy']).not_to be_nil
    expect(Rake::Task['network:output']).not_to be_nil
  end

  context 'validate task' do
    it 'configures with the provided configuration name ' +
           'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      validate_configurer = stubbed_validate_configurer

      expect(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:configuration_name=).with(configuration_name))
      expect(validate_configurer)
          .to(receive(:source_directory=).with(source_directory))
      expect(validate_configurer)
          .to(receive(:work_directory=).with(work_directory))


      namespace :network do
        define_tasks do |t|
          t.configuration_name = configuration_name
          t.source_directory = source_directory
          t.work_directory = work_directory
        end
      end
    end

    it 'passes backend configuration when present' do
      backend_config = {
          bucket: 'some-bucket'
      }

      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:backend_config=).with(backend_config))

      namespace :network do
        define_tasks do |t|
          t.backend_config = backend_config
        end
      end
    end

    it 'passes nil for backend configuration when not present' do
      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
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

      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:vars=).with(vars))

      namespace :network do
        define_tasks do |t|
          t.vars = vars
        end
      end
    end

    it 'passes nil for vars when no vars present' do
      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:vars=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:state_file=).with(state_file))

      namespace :network do
        define_tasks do |t|
          t.state_file = state_file
        end
      end
    end

    it 'passes nil for state file when no state file present' do
      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:state_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:no_color=).with(no_color))

      namespace :network do
        define_tasks do |t|
          t.no_color = no_color
        end
      end
    end

    it 'passes false for no_color by default' do
      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:no_color=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes provided ensure task when present' do
      ensure_task = :'tooling:terraform:ensure'

      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:ensure_task=).with(ensure_task))

      namespace :network do
        define_tasks do |t|
          t.ensure_task = ensure_task
        end
      end
    end

    it 'passes terraform:ensure for ensure task by default' do
      validate_configurer = stubbed_validate_configurer

      allow(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:ensure_task=).with(:'terraform:ensure'))

      namespace :network do
        define_tasks
      end
    end

    it 'uses a name of validate by default' do
      validate_configurer = stubbed_validate_configurer

      expect(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:name=).with(:validate))

      define_tasks
    end

    it 'uses the provided name when supplied' do
      validate_configurer = stubbed_validate_configurer

      expect(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:name=).with(:prepare_the_validates))

      define_tasks do |t|
        t.validate_task_name = :prepare_the_validates
      end
    end

    it 'passes the provided argument names when supplied' do
      validate_configurer = stubbed_validate_configurer

      expect(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.validate_argument_names = [:deployment_identifier, :region]
      end
    end

    it 'passes the provided argument names when supplied' do
      validate_configurer = stubbed_validate_configurer

      expect(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
      end
    end

    it 'gives preference to the validate argument names when argument names ' +
           'also provided' do
      validate_configurer = stubbed_validate_configurer

      expect(RakeTerraform::Tasks::Validate)
          .to(receive(:new).and_yield(validate_configurer))
      expect(validate_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
        t.validate_argument_names = [:deployment_identifier]
      end
    end
  end

  context 'plan task' do
    it 'configures with the provided configuration name ' +
           'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      plan_configurer = stubbed_plan_configurer

      expect(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:configuration_name=).with(configuration_name))
      expect(plan_configurer)
          .to(receive(:source_directory=).with(source_directory))
      expect(plan_configurer)
          .to(receive(:work_directory=).with(work_directory))


      namespace :network do
        define_tasks do |t|
          t.configuration_name = configuration_name
          t.source_directory = source_directory
          t.work_directory = work_directory
        end
      end
    end

    it 'passes backend configuration when present' do
      backend_config = {
          bucket: 'some-bucket'
      }

      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:backend_config=).with(backend_config))

      namespace :network do
        define_tasks do |t|
          t.backend_config = backend_config
        end
      end
    end

    it 'passes nil for backend configuration when not present' do
      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
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

      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:vars=).with(vars))

      namespace :network do
        define_tasks do |t|
          t.vars = vars
        end
      end
    end

    it 'passes nil for vars when no vars present' do
      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:vars=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:state_file=).with(state_file))

      namespace :network do
        define_tasks do |t|
          t.state_file = state_file
        end
      end
    end

    it 'passes nil for state file when no state file present' do
      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:state_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes plan file when present' do
      plan_file = 'infra/terraform.tfplan'

      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:plan_file=).with(plan_file))

      namespace :network do
        define_tasks do |t|
          t.plan_file = plan_file
        end
      end
    end

    it 'passes nil for plan file when no plan file present' do
      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:plan_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:no_color=).with(no_color))

      namespace :network do
        define_tasks do |t|
          t.no_color = no_color
        end
      end
    end

    it 'passes false for no_color by default' do
      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:no_color=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes provided ensure task when present' do
      ensure_task = :'tooling:terraform:ensure'

      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:ensure_task=).with(ensure_task))

      namespace :network do
        define_tasks do |t|
          t.ensure_task = ensure_task
        end
      end
    end

    it 'passes terraform:ensure for ensure task by default' do
      plan_configurer = stubbed_plan_configurer

      allow(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:ensure_task=).with(:'terraform:ensure'))

      namespace :network do
        define_tasks
      end
    end

    it 'uses a name of plan by default' do
      plan_configurer = stubbed_plan_configurer

      expect(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:name=).with(:plan))

      define_tasks
    end

    it 'uses the provided name when supplied' do
      plan_configurer = stubbed_plan_configurer

      expect(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:name=).with(:prepare_the_plans))

      define_tasks do |t|
        t.plan_task_name = :prepare_the_plans
      end
    end

    it 'passes the provided argument names when supplied' do
      plan_configurer = stubbed_plan_configurer

      expect(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.plan_argument_names = [:deployment_identifier, :region]
      end
    end

    it 'passes the provided argument names when supplied' do
      plan_configurer = stubbed_plan_configurer

      expect(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
      end
    end

    it 'gives preference to the plan argument names when argument names ' +
           'also provided' do
      plan_configurer = stubbed_plan_configurer

      expect(RakeTerraform::Tasks::Plan)
          .to(receive(:new).and_yield(plan_configurer))
      expect(plan_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
        t.plan_argument_names = [:deployment_identifier]
      end
    end
  end

  context 'provision task' do
    it 'configures with the provided configuration name ' +
           'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      provision_configurer = stubbed_provision_configurer

      expect(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:configuration_name=).with(configuration_name))
      expect(provision_configurer)
          .to(receive(:source_directory=).with(source_directory))
      expect(provision_configurer)
          .to(receive(:work_directory=).with(work_directory))

      namespace :network do
        define_tasks do |t|
          t.configuration_name = configuration_name
          t.source_directory = source_directory
          t.work_directory = work_directory
        end
      end
    end

    it 'passes backend configuration when present' do
      backend_config = {
          bucket: 'some-bucket'
      }

      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:backend_config=).with(backend_config))

      namespace :network do
        define_tasks do |t|
          t.backend_config = backend_config
        end
      end
    end

    it 'passes nil for backend configuration when not present' do
      provision_configurer = stubbed_provision_configurer

      allow(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
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

    it 'passes the provided argument names when supplied' do
      provision_configurer = stubbed_provision_configurer

      expect(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.provision_argument_names = [:deployment_identifier, :region]
      end
    end

    it 'passes the provided argument names when supplied' do
      provision_configurer = stubbed_provision_configurer

      expect(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
      end
    end

    it 'gives preference to the provision argument names when argument names ' +
           'also provided' do
      provision_configurer = stubbed_provision_configurer

      expect(RakeTerraform::Tasks::Provision)
          .to(receive(:new).and_yield(provision_configurer))
      expect(provision_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
        t.provision_argument_names = [:deployment_identifier]
      end
    end
  end

  context 'destroy task' do
    it 'configures with the provided configuration name ' +
           'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      destroy_configurer = stubbed_destroy_configurer

      expect(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:configuration_name=).with(configuration_name))
      expect(destroy_configurer)
          .to(receive(:work_directory=).with(work_directory))
      expect(destroy_configurer)
          .to(receive(:source_directory=).with(source_directory))

      namespace :network do
        define_tasks do |t|
          t.configuration_name = configuration_name
          t.source_directory = source_directory
          t.work_directory = work_directory
        end
      end
    end

    it 'passes backend configuration when present' do
      backend_config = {
          bucket: 'some-bucket'
      }

      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:backend_config=).with(backend_config))

      namespace :network do
        define_tasks do |t|
          t.backend_config = backend_config
        end
      end
    end

    it 'passes nil for backend when no backend configuration present' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
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

    it 'passes false for no_backup by default' do
      destroy_configurer = stubbed_destroy_configurer

      allow(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:no_backup=).with(false))

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

    it 'passes the provided destroy argument names when supplied' do
      destroy_configurer = stubbed_destroy_configurer

      expect(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.destroy_argument_names = [:deployment_identifier, :region]
      end
    end

    it 'passes the provided argument names when supplied' do
      destroy_configurer = stubbed_destroy_configurer

      expect(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
      end
    end

    it 'gives preference to the destroy argument names when argument names also provided' do
      destroy_configurer = stubbed_destroy_configurer

      expect(RakeTerraform::Tasks::Destroy)
          .to(receive(:new).and_yield(destroy_configurer))
      expect(destroy_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
        t.destroy_argument_names = [:deployment_identifier]
      end
    end
  end

  context 'output task' do
    it 'configures with the provided configuration name ' +
           'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      output_configurer = stubbed_output_configurer

      expect(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:configuration_name=).with(configuration_name))
      expect(output_configurer)
          .to(receive(:work_directory=).with(work_directory))
      expect(output_configurer)
          .to(receive(:source_directory=).with(source_directory))

      namespace :network do
        define_tasks do |t|
          t.configuration_name = configuration_name
          t.source_directory = source_directory
          t.work_directory = work_directory
        end
      end
    end

    it 'passes backend configuration when present' do
      backend_config = {
          bucket: 'some-bucket'
      }

      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:backend_config=).with(backend_config))

      namespace :network do
        define_tasks do |t|
          t.backend_config = backend_config
        end
      end
    end

    it 'passes nil for backend when no backend configuration present' do
      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:backend_config=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:state_file=).with(state_file))

      namespace :network do
        define_tasks do |t|
          t.state_file = state_file
        end
      end
    end

    it 'passes nil for state file when no state file present' do
      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:state_file=).with(nil))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:no_color=).with(no_color))

      namespace :network do
        define_tasks do |t|
          t.no_color = no_color
        end
      end
    end

    it 'passes false for no_color by default' do
      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:no_color=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes supplied value for no_print_output when provided' do
      no_print_output = true

      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:no_print_output=).with(no_print_output))

      namespace :network do
        define_tasks do |t|
          t.no_print_output = no_print_output
        end
      end
    end

    it 'passes false for no_print_output by default' do
      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:no_print_output=).with(false))

      namespace :network do
        define_tasks
      end
    end

    it 'passes provided ensure task when present' do
      ensure_task = :'tooling:terraform:ensure'

      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:ensure_task=).with(ensure_task))

      namespace :network do
        define_tasks do |t|
          t.ensure_task = ensure_task
        end
      end
    end

    it 'passes terraform:ensure for ensure task by default' do
      output_configurer = stubbed_output_configurer

      allow(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:ensure_task=).with(:'terraform:ensure'))

      namespace :network do
        define_tasks
      end
    end

    it 'uses a name of output by default' do
      output_configurer = stubbed_output_configurer

      expect(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:name=).with(:output))

      define_tasks
    end

    it 'uses the provided name when supplied' do
      output_configurer = stubbed_output_configurer

      expect(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:name=).with(:deploy))

      define_tasks do |t|
        t.output_task_name = :deploy
      end
    end

    it 'passes the provided output argument names when supplied' do
      output_configurer = stubbed_output_configurer

      expect(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.output_argument_names = [:deployment_identifier, :region]
      end
    end

    it 'passes the provided argument names when supplied' do
      output_configurer = stubbed_output_configurer

      expect(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier, :region]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
      end
    end

    it 'gives preference to the output argument names when argument names also provided' do
      output_configurer = stubbed_output_configurer

      expect(RakeTerraform::Tasks::Output)
          .to(receive(:new).and_yield(output_configurer))
      expect(output_configurer)
          .to(receive(:argument_names=).with([:deployment_identifier]))

      define_tasks do |t|
        t.argument_names = [:deployment_identifier, :region]
        t.output_argument_names = [:deployment_identifier]
      end
    end
  end

  def define_tasks(&block)
    subject.new do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

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

  def stubbed_validate_configurer
    double_allowing(
        :name=, :argument_names=, :backend_config=,
        :configuration_name=, :source_directory=, :work_directory=,
        :vars=, :state_file=,
        :no_color=,
        :ensure_task=)
  end

  def stubbed_plan_configurer
    double_allowing(
        :name=, :argument_names=, :backend_config=,
        :configuration_name=, :source_directory=, :work_directory=,
        :vars=, :state_file=,
        :no_color=, :plan_file=, :destroy=,
        :ensure_task=)
  end

  def stubbed_provision_configurer
    double_allowing(
        :name=, :argument_names=, :backend_config=,
        :configuration_name=, :source_directory=, :work_directory=,
        :vars=, :state_file=,
        :no_color=, :no_backup=, :backup_file=,
        :ensure_task=)
  end

  def stubbed_destroy_configurer
    double_allowing(
        :name=, :argument_names=, :backend_config=,
        :configuration_name=, :source_directory=, :work_directory=,
        :vars=, :state_file=,
        :no_color=, :no_backup=, :backup_file=,
        :ensure_task=)
  end

  def stubbed_output_configurer
    double_allowing(
        :name=, :argument_names=, :backend_config=,
        :configuration_name=, :source_directory=, :work_directory=,
        :vars=, :state_file=,
        :no_color=, :no_print_output=,
        :ensure_task=)
  end
end
