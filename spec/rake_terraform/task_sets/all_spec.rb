# frozen_string_literal: true

require 'spec_helper'

describe RakeTerraform::TaskSets::All do
  include_context 'with rake'

  def define_tasks(opts = {}, &block)
    described_class.define({
      configuration_name: 'network',
      source_directory: 'infra/network',
      work_directory: 'build'
    }.merge(opts), &block)
  end

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

  describe 'validate task' do
    it 'configures with the provided configuration name ' \
       'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      namespace :network do
        define_tasks(
          configuration_name: configuration_name,
          source_directory: source_directory,
          work_directory: work_directory
        )
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.configuration_name).to(eq(configuration_name))
      expect(rake_task.creator.source_directory).to(eq(source_directory))
      expect(rake_task.creator.work_directory).to(eq(work_directory))
    end

    it 'passes backend configuration when present' do
      backend_config = {
        bucket: 'some-bucket'
      }

      namespace :network do
        define_tasks(backend_config: backend_config)
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.backend_config).to(eq(backend_config))
    end

    it 'passes nil for backend configuration when not present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.backend_config).to(be_nil)
    end

    it 'passes supplied value for debug when provided' do
      debug = true

      namespace :network do
        define_tasks(debug: debug)
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.debug).to(eq(debug))
    end

    it 'uses default for debug by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.debug).to(eq(false))
    end

    it 'passes supplied value for input when provided' do
      input = true

      namespace :network do
        define_tasks(input: input)
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.input).to(eq(input))
    end

    it 'uses default for input by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.input).to(eq(false))
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      namespace :network do
        define_tasks(no_color: no_color)
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.no_color).to(eq(true))
    end

    it 'uses default for no_color by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.no_color).to(eq(false))
    end

    it 'passes provided ensure task when present' do
      ensure_task_name = :'tooling:terraform:ensure'

      namespace :network do
        define_tasks(ensure_task_name: ensure_task_name)
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.ensure_task_name).to(eq(ensure_task_name))
    end

    it 'passes terraform:ensure for ensure task by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:validate']

      expect(rake_task.creator.ensure_task_name).to(eq(:'terraform:ensure'))
    end

    it 'uses a name of validate by default' do
      define_tasks

      rake_task = Rake::Task['validate']

      expect(rake_task.creator.name).to(eq(:validate))
    end

    it 'uses the provided name when supplied' do
      define_tasks(validate_task_name: :prepare_the_validates)

      expect(Rake::Task.task_defined?('prepare_the_validates')).to(be(true))
    end

    it 'passes the provided validate argument names when supplied' do
      argument_names = %i[deployment_identifier region]

      define_tasks(validate_argument_names: argument_names)

      rake_task = Rake::Task['validate']

      expect(rake_task.arg_names).to(eq(argument_names))
    end

    it 'passes the provided argument names when supplied' do
      argument_names = %i[deployment_identifier region]

      define_tasks(argument_names: argument_names)

      rake_task = Rake::Task['validate']

      expect(rake_task.arg_names).to(eq(argument_names))
    end

    it 'gives preference to the validate argument names when argument names ' \
       'also provided' do
      define_tasks(
        argument_names: %i[deployment_identifier region],
        validate_argument_names: [:deployment_identifier]
      )

      rake_task = Rake::Task['validate']

      expect(rake_task.arg_names).to(eq([:deployment_identifier]))
    end
  end

  describe 'plan task' do
    it 'configures with the provided configuration name ' \
       'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      namespace :network do
        define_tasks(
          configuration_name: configuration_name,
          source_directory: source_directory,
          work_directory: work_directory
        )
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.configuration_name).to(eq(configuration_name))
      expect(rake_task.creator.source_directory).to(eq(source_directory))
      expect(rake_task.creator.work_directory).to(eq(work_directory))
    end

    it 'passes backend configuration when present' do
      backend_config = {
        bucket: 'some-bucket'
      }

      namespace :network do
        define_tasks(backend_config: backend_config)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.backend_config).to(eq(backend_config))
    end

    it 'passes nil for backend configuration when not present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.backend_config).to(be_nil)
    end

    it 'passes vars when present' do
      vars = {
        vpc_id: '1234',
        domain_name: 'example.com'
      }

      namespace :network do
        define_tasks(vars: vars)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.vars).to(eq(vars))
    end

    it 'uses default for vars when no vars present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.vars).to(eq({}))
    end

    it 'passes var file when present' do
      var_file = 'some/terraform.tfvars'

      namespace :network do
        define_tasks(var_file: var_file)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.var_file).to(eq(var_file))
    end

    it 'passes nil for var file when no var file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.var_file).to(be_nil)
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      namespace :network do
        define_tasks(state_file: state_file)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.state_file).to(eq(state_file))
    end

    it 'passes nil for state file when no state file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.state_file).to(be_nil)
    end

    it 'passes plan file when present' do
      plan_file = 'infra/terraform.tfplan'

      namespace :network do
        define_tasks(plan_file: plan_file)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.plan_file).to(eq(plan_file))
    end

    it 'passes nil for plan file when no plan file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.plan_file).to(be_nil)
    end

    it 'passes supplied value for debug when provided' do
      debug = true

      namespace :network do
        define_tasks(debug: debug)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.debug).to(eq(debug))
    end

    it 'passes false for debug by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.debug).to(eq(false))
    end

    it 'passes supplied value for input when provided' do
      input = true

      namespace :network do
        define_tasks(input: input)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.input).to(eq(input))
    end

    it 'passes false for input by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.input).to(eq(false))
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      namespace :network do
        define_tasks(no_color: no_color)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.no_color).to(eq(no_color))
    end

    it 'passes false for no_color by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.no_color).to(eq(false))
    end

    it 'passes provided ensure task when present' do
      ensure_task_name = :'tooling:terraform:ensure'

      namespace :network do
        define_tasks(ensure_task_name: ensure_task_name)
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.ensure_task_name).to(eq(ensure_task_name))
    end

    it 'passes terraform:ensure for ensure task by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:plan']

      expect(rake_task.creator.ensure_task_name).to(eq(:'terraform:ensure'))
    end

    it 'uses a name of plan by default' do
      define_tasks

      expect(Rake::Task.task_defined?('plan')).to(be(true))
    end

    it 'uses the provided name when supplied' do
      define_tasks(plan_task_name: :prepare_the_plans)

      expect(Rake::Task.task_defined?('prepare_the_plans')).to(be(true))
    end

    it 'passes the provided specific argument names when supplied' do
      define_tasks(plan_argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['plan']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'passes the provided global argument names when supplied' do
      define_tasks(argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['plan']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'gives preference to the plan argument names when argument names ' \
       'also provided' do
      define_tasks(
        argument_names: %i[deployment_identifier region],
        plan_argument_names: [:deployment_identifier]
      )

      rake_task = Rake::Task['plan']

      expect(rake_task.arg_names).to(eq([:deployment_identifier]))
    end
  end

  describe 'provision task' do
    it 'configures with the provided configuration name ' \
       'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      namespace :network do
        define_tasks(
          configuration_name: configuration_name,
          source_directory: source_directory,
          work_directory: work_directory
        )
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.configuration_name)
        .to(eq(configuration_name))
      expect(rake_task.creator.source_directory)
        .to(eq(source_directory))
      expect(rake_task.creator.work_directory)
        .to(eq(work_directory))
    end

    it 'passes backend configuration when present' do
      backend_config = {
        bucket: 'some-bucket'
      }

      namespace :network do
        define_tasks(backend_config: backend_config)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.backend_config).to(eq(backend_config))
    end

    it 'passes nil for backend configuration when not present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.backend_config).to(be_nil)
    end

    it 'passes vars when present' do
      vars = {
        vpc_id: '1234',
        domain_name: 'example.com'
      }

      namespace :network do
        define_tasks(vars: vars)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.vars).to(eq(vars))
    end

    it 'uses default for vars when no vars present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.vars).to(eq({}))
    end

    it 'passes var file when present' do
      var_file = 'some/terraform.tfvars'

      namespace :network do
        define_tasks(var_file: var_file)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.var_file).to(eq(var_file))
    end

    it 'passes nil for var file when no var file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.var_file).to(be_nil)
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      namespace :network do
        define_tasks(state_file: state_file)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.state_file).to(eq(state_file))
    end

    it 'passes nil for state file when no state file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.state_file).to(be_nil)
    end

    it 'passes supplied value for debug when provided' do
      debug = true

      namespace :network do
        define_tasks(debug: debug)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.debug).to(eq(debug))
    end

    it 'passes false for debug by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.debug).to(eq(false))
    end

    it 'passes supplied value for input when provided' do
      input = true

      namespace :network do
        define_tasks(input: input)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.input).to(eq(input))
    end

    it 'passes false for input by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.input).to(eq(false))
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      namespace :network do
        define_tasks(no_color: no_color)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.no_color).to(eq(no_color))
    end

    it 'passes false for no_color by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.no_color).to(eq(false))
    end

    it 'passes supplied value for no_backup when provided' do
      no_backup = true

      namespace :network do
        define_tasks(no_backup: no_backup)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.no_backup).to(eq(no_backup))
    end

    it 'passes false for no_backup by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.no_backup).to(eq(false))
    end

    it 'passes provided backup file when present' do
      backup_file = 'infra/terraform.tfstate.backup'

      namespace :network do
        define_tasks(backup_file: backup_file)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.backup_file).to(eq(backup_file))
    end

    it 'passes nil for backup file when no backup file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.backup_file).to(be_nil)
    end

    it 'passes provided ensure task when present' do
      ensure_task_name = :'tooling:terraform:ensure'

      namespace :network do
        define_tasks(ensure_task_name: ensure_task_name)
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.ensure_task_name).to(eq(ensure_task_name))
    end

    it 'passes terraform:ensure for ensure task by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:provision']

      expect(rake_task.creator.ensure_task_name).to(eq(:'terraform:ensure'))
    end

    it 'uses a name of provision by default' do
      define_tasks

      expect(Rake::Task.task_defined?('provision')).to(be(true))
    end

    it 'uses the provided name when supplied' do
      define_tasks(provision_task_name: :deploy)

      expect(Rake::Task.task_defined?('deploy')).to(be(true))
    end

    it 'passes the provided specific argument names when supplied' do
      define_tasks(provision_argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['provision']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'passes the provided global argument names when supplied' do
      define_tasks(argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['provision']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'gives preference to the specific argument names when global ' \
       'argument names also provided' do
      define_tasks(
        argument_names: %i[deployment_identifier region],
        provision_argument_names: [:deployment_identifier]
      )

      rake_task = Rake::Task['provision']

      expect(rake_task.arg_names).to(eq([:deployment_identifier]))
    end
  end

  describe 'destroy task' do
    it 'configures with the provided configuration name ' \
       'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      namespace :network do
        define_tasks(
          configuration_name: configuration_name,
          source_directory: source_directory,
          work_directory: work_directory
        )
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.configuration_name)
        .to(eq(configuration_name))
      expect(rake_task.creator.source_directory)
        .to(eq(source_directory))
      expect(rake_task.creator.work_directory)
        .to(eq(work_directory))
    end

    it 'passes backend configuration when present' do
      backend_config = {
        bucket: 'some-bucket'
      }

      namespace :network do
        define_tasks(backend_config: backend_config)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.backend_config).to(eq(backend_config))
    end

    it 'passes nil for backend when no backend configuration present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.backend_config).to(be_nil)
    end

    it 'passes vars when present' do
      vars = {
        vpc_id: '1234',
        domain_name: 'example.com'
      }

      namespace :network do
        define_tasks(vars: vars)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.vars).to(eq(vars))
    end

    it 'uses default for vars when no vars present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.vars).to(eq({}))
    end

    it 'passes var file when present' do
      var_file = 'some/terraform.tfvars'

      namespace :network do
        define_tasks(var_file: var_file)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.var_file).to(eq(var_file))
    end

    it 'passes nil for var file when no var file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.var_file).to(be_nil)
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      namespace :network do
        define_tasks(state_file: state_file)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.state_file).to(eq(state_file))
    end

    it 'passes nil for state file when no state file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.state_file).to(be_nil)
    end

    it 'passes supplied value for debug when provided' do
      debug = true

      namespace :network do
        define_tasks(debug: debug)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.debug).to(eq(debug))
    end

    it 'passes false for debug by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.debug).to(eq(false))
    end

    it 'passes supplied value for input when provided' do
      input = true

      namespace :network do
        define_tasks(input: input)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.input).to(eq(input))
    end

    it 'passes false for input by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.input).to(eq(false))
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      namespace :network do
        define_tasks(no_color: no_color)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.no_color).to(eq(no_color))
    end

    it 'passes false for no_color by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.no_color).to(eq(false))
    end

    it 'passes supplied value for no_backup when provided' do
      no_backup = true

      namespace :network do
        define_tasks(no_backup: no_backup)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.no_backup).to(eq(no_backup))
    end

    it 'passes false for no_backup by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.no_backup).to(eq(false))
    end

    it 'passes provided backup file when present' do
      backup_file = 'infra/terraform.tfstate.backup'

      namespace :network do
        define_tasks(backup_file: backup_file)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.backup_file).to(eq(backup_file))
    end

    it 'passes nil for backup file when no backup file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.backup_file).to(be_nil)
    end

    it 'passes provided ensure task when present' do
      ensure_task_name = :'tooling:terraform:ensure'

      namespace :network do
        define_tasks(ensure_task_name: ensure_task_name)
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.ensure_task_name)
        .to(eq(ensure_task_name))
    end

    it 'passes terraform:ensure for ensure task by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:destroy']

      expect(rake_task.creator.ensure_task_name).to(eq(:'terraform:ensure'))
    end

    it 'uses a name of destroy by default' do
      define_tasks

      expect(Rake::Task.task_defined?('destroy')).to(be(true))
    end

    it 'uses the provided name when supplied' do
      define_tasks(destroy_task_name: :obliterate)

      expect(Rake::Task.task_defined?('obliterate')).to(be(true))
    end

    it 'passes the provided destroy argument names when supplied' do
      define_tasks(destroy_argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['destroy']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'passes the provided argument names when supplied' do
      define_tasks(argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['destroy']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'gives preference to the destroy argument names when argument names ' \
       'also provided' do
      define_tasks(
        argument_names: %i[deployment_identifier region],
        destroy_argument_names: [:deployment_identifier]
      )

      rake_task = Rake::Task['destroy']

      expect(rake_task.arg_names).to(eq([:deployment_identifier]))
    end
  end

  describe 'output task' do
    it 'configures with the provided configuration name ' \
       'source directory and work directory' do
      configuration_name = 'network'
      source_directory = 'infra/network'
      work_directory = 'build'

      namespace :network do
        define_tasks(
          configuration_name: configuration_name,
          source_directory: source_directory,
          work_directory: work_directory
        )
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.configuration_name).to(eq(configuration_name))
      expect(rake_task.creator.work_directory).to(eq(work_directory))
      expect(rake_task.creator.source_directory).to(eq(source_directory))
    end

    it 'passes backend configuration when present' do
      backend_config = {
        bucket: 'some-bucket'
      }

      namespace :network do
        define_tasks(backend_config: backend_config)
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.backend_config).to(eq(backend_config))
    end

    it 'passes nil for backend when no backend configuration present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.backend_config).to(be_nil)
    end

    it 'passes state file when present' do
      state_file = 'infra/terraform.tfstate'

      namespace :network do
        define_tasks(state_file: state_file)
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.state_file).to(eq(state_file))
    end

    it 'passes nil for state file when no state file present' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.state_file).to(be_nil)
    end

    it 'passes supplied value for debug when provided' do
      debug = true

      namespace :network do
        define_tasks(debug: debug)
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.debug).to(eq(debug))
    end

    it 'passes false for debug by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.debug).to(eq(false))
    end

    it 'passes supplied value for input when provided' do
      input = true

      namespace :network do
        define_tasks(input: input)
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.input).to(eq(input))
    end

    it 'passes false for input by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.input).to(eq(false))
    end

    it 'passes supplied value for no_color when provided' do
      no_color = true

      namespace :network do
        define_tasks(no_color: no_color)
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.no_color).to(eq(no_color))
    end

    it 'passes false for no_color by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.no_color).to(eq(false))
    end

    it 'passes supplied value for no_print_output when provided' do
      no_print_output = true

      namespace :network do
        define_tasks(no_print_output: no_print_output)
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.no_print_output).to(eq(no_print_output))
    end

    it 'passes false for no_print_output by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.no_print_output).to(eq(false))
    end

    it 'passes provided ensure task when present' do
      ensure_task_name = :'tooling:terraform:ensure'

      namespace :network do
        define_tasks(ensure_task_name: ensure_task_name)
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.ensure_task_name).to(eq(ensure_task_name))
    end

    it 'passes terraform:ensure for ensure task by default' do
      namespace :network do
        define_tasks
      end

      rake_task = Rake::Task['network:output']

      expect(rake_task.creator.ensure_task_name).to(eq(:'terraform:ensure'))
    end

    it 'uses a name of output by default' do
      define_tasks

      expect(Rake::Task.task_defined?('output')).to(eq(true))
    end

    it 'uses the provided name when supplied' do
      define_tasks(output_task_name: :print_output)

      expect(Rake::Task.task_defined?('print_output')).to(eq(true))
    end

    it 'passes the provided output argument names when supplied' do
      define_tasks(output_argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['output']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'passes the provided argument names when supplied' do
      define_tasks(argument_names: %i[deployment_identifier region])

      rake_task = Rake::Task['output']

      expect(rake_task.arg_names).to(eq(%i[deployment_identifier region]))
    end

    it 'gives preference to the output argument names when argument names ' \
       'also provided' do
      define_tasks(
        argument_names: %i[deployment_identifier region],
        output_argument_names: [:deployment_identifier]
      )

      rake_task = Rake::Task['output']

      expect(rake_task.arg_names).to(eq([:deployment_identifier]))
    end
  end
end
