# frozen_string_literal: true

require 'ruby_terraform'
require 'spec_helper'

describe RakeTerraform::Tasks::Destroy do
  include_context 'with rake'

  before do
    namespace :terraform do
      task :ensure
    end
  end

  it 'adds a destroy task in the namespace in which it is created' do
    namespace :infrastructure do
      described_class.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:destroy']).not_to be_nil
  end

  it 'gives the destroy task a description' do
    namespace :dependency do
      described_class.define(configuration_name: 'network') do |t|
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['dependency:destroy'].full_comment)
      .to(eq('Destroy network using terraform'))
  end

  it 'allows the task name to be overridden' do
    namespace :infrastructure do
      described_class.define(
        name: :destroy_network,
        configuration_name: 'network'
      ) do |t|
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task.task_defined?('infrastructure:destroy_network'))
      .to(be(true))
  end

  it 'allows multiple destroy tasks to be declared' do
    namespace :infra1 do
      described_class.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    namespace :infra2 do
      described_class.define do |t|
        t.configuration_name = 'database'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    infra1_destroy = Rake::Task['infra1:destroy']
    infra2_destroy = Rake::Task['infra2:destroy']

    expect(infra1_destroy).not_to be_nil
    expect(infra2_destroy).not_to be_nil
  end

  it 'depends on the terraform:ensure task by default' do
    namespace :infrastructure do
      described_class.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:destroy'].prerequisite_tasks)
      .to(include(Rake::Task['terraform:ensure']))
  end

  it 'depends on the provided task if specified' do
    namespace :tools do
      namespace :terraform do
        task :ensure
      end
    end

    namespace :infrastructure do
      described_class.define(
        name: :destroy,
        ensure_task_name: 'tools:terraform:ensure'
      ) do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:destroy'].prerequisite_tasks)
      .to(include(Rake::Task['tools:terraform:ensure']))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = %i[deployment_identifier region]

    namespace :infrastructure do
      described_class.define(argument_names: argument_names) do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:destroy'].arg_names)
      .to(eq(argument_names))
  end

  it 'cleans the configuration directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(FileUtils)
      .to(have_received(:rm_rf)
            .with(configuration_directory))
  end

  it 'recursively makes the configuration directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/infra/network"

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(FileUtils)
      .to(have_received(:mkdir_p)
            .with(configuration_directory))
  end

  it 'initialises the configuration directory' do
    source_directory = 'infra/network'
    work_directory = 'build'

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init))
  end

  it 'passes a no_color parameter of false to init by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(no_color: false), anything))
  end

  it 'passes the provided value for the no_color parameter to init ' \
     'when present' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.no_color = true
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(no_color: true), anything))
  end

  it 'passes an empty environment parameter to init by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(anything, { environment: {} }))
  end

  it 'passes the provided value for the environment parameter to init ' \
     'when present' do
    environment = {
      'SOME_ENV' => 'some-value'
    }

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.environment = environment
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(anything, { environment: environment }))
  end

  it 'passes the configuration directory as chdir parameter to init' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(chdir: configuration_directory), anything))
  end

  it 'passes the absolute source directory as from module parameter to init' do
    source_directory = 'infra/network'
    work_directory = 'build'
    current_directory = '/path/to/project'
    absolute_source_directory = "#{current_directory}/#{source_directory}"

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    allow(FileUtils)
      .to(receive(:pwd))
      .and_return(current_directory)

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(from_module: absolute_source_directory),
                  anything))
  end

  it 'passes an input parameter of false to init by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(input: false), anything))
  end

  it 'passes the provided value for the input parameter to init ' \
     'when present' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.input = true
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(input: true), anything))
  end

  it 'passes the provided backend config to init when present' do
    described_class.define(
      argument_names: [:bucket_name]
    ) do |t, args|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backend_config = {
        bucket: args.bucket_name,
        key: "#{t.configuration_name}.tfstate",
        region: 'eu-west-2'
      }
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke('bucket-from-args')

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(
                    backend_config: {
                      bucket: 'bucket-from-args',
                      key: 'network.tfstate',
                      region: 'eu-west-2'
                    }
                  ),
                  anything))
  end

  it 'destroys the configuration' do
    source_directory = 'infra/network'
    work_directory = 'build'

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy), anything)
  end

  it 'passes the configuration directory as chdir parameter to apply' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(chdir: configuration_directory), anything))
  end

  it 'uses the provided vars map in the terraform destroy call' do
    described_class.define(
      argument_names: [:deployment_identifier]
    ) do |t, args|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backend_config = {
        bucket: 'some-bucket'
      }

      t.vars = {
        deployment_identifier: args.deployment_identifier,
        configuration_name: t.configuration_name,
        state_bucket: t.backend_config[:bucket]
      }
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke('staging')

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(
                    vars: {
                      deployment_identifier: 'staging',
                      configuration_name: 'network',
                      state_bucket: 'some-bucket'
                    }
                  ),
                  anything))
  end

  it 'uses the provided var file when present' do
    var_file = 'some/terraform.tfvars'

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.var_file = var_file
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(var_file: var_file), anything))
  end

  it 'uses the provided state file when present' do
    described_class.define(
      argument_names: [:deployment_identifier]
    ) do |t, args|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.state_file =
        "path/to/state/#{args.deployment_identifier}/" \
        "#{t.configuration_name}.tfstate"
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke('staging')

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(
                    state: 'path/to/state/staging/network.tfstate'
                  ),
                  anything))
  end

  it 'passes an input parameter of false to destroy by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(input: false), anything))
  end

  it 'passes the provided value for the input parameter to destroy ' \
     'when present' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.input = true
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(input: true), anything))
  end

  it 'passes a no_color parameter of false to destroy by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(no_color: false), anything))
  end

  it 'passes the provided value for the no_color parameter to destroy ' \
     'when present' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.no_color = true
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(no_color: true), anything))
  end

  it 'passes an empty environment parameter to destroy by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(anything, { environment: {} }))
  end

  it 'passes the provided value for the environment parameter to destroy ' \
     'when present' do
    environment = {
      'SOME_ENV' => 'some-value'
    }

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.environment = environment
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(anything, { environment: environment }))
  end

  it 'passes a no_backup parameter of false to destroy by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(no_backup: false), anything))
  end

  it 'passes the provided value for the no_backup parameter to destroy ' \
     'when present' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.no_backup = true
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(no_backup: true), anything))
  end

  it 'passes a backup parameter of nil to destroy by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(backup: nil), anything))
  end

  it 'passes the provided backup_file value for the backup parameter to ' \
     'destroy when present' do
    backup_file = 'some/state.tfstate.backup'

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backup_file = backup_file
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(backup: backup_file), anything))
  end

  it 'passes auto_approve as true to destroy' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['destroy'].invoke

    expect(RubyTerraform)
      .to(have_received(:destroy)
            .with(hash_including(auto_approve: true), anything))
  end

  def stub_puts
    allow(Kernel).to(receive(:puts))
  end

  def stub_fs
    allow(FileUtils).to(receive(:pwd)).and_return('/')
    allow(FileUtils).to(receive(:rm_rf))
    allow(FileUtils).to(receive(:mkdir_p))
  end

  def stub_ruby_terraform
    allow(RubyTerraform).to(receive(:init))
    allow(RubyTerraform).to(receive(:destroy))
  end
end
