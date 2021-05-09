# frozen_string_literal: true

require 'ruby_terraform'
require 'spec_helper'

describe RakeTerraform::Tasks::Provision do
  include_context 'with rake'

  before do
    namespace :terraform do
      task :ensure
    end
  end

  it 'adds a provision task in the namespace in which it is created' do
    namespace :infrastructure do
      described_class.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task.task_defined?('infrastructure:provision'))
      .to(be(true))
  end

  it 'gives the provision task a description' do
    namespace :dependency do
      described_class.define(configuration_name: 'network') do |t|
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['dependency:provision'].full_comment)
      .to(eq('Provision network using terraform'))
  end

  it 'allows the task name to be overridden' do
    namespace :infrastructure do
      described_class.define(name: :provision_network) do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(
      Rake::Task.task_defined?(
        'infrastructure:provision_network'
      )
    ).to(be(true))
  end

  it 'allows multiple provision tasks to be declared' do
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

    infra1_provision = Rake::Task['infra1:provision']
    infra2_provision = Rake::Task['infra2:provision']

    expect(infra1_provision).not_to be_nil
    expect(infra2_provision).not_to be_nil
  end

  it 'depends on the terraform:ensure task by default' do
    namespace :infrastructure do
      described_class.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:provision'].prerequisite_tasks)
      .to(include(Rake::Task['terraform:ensure']))
  end

  it 'depends on the provided task if specified' do
    namespace :tools do
      namespace :terraform do
        task :ensure
      end
    end

    namespace :infrastructure do
      described_class.define(ensure_task_name: 'tools:terraform:ensure') do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:provision'].prerequisite_tasks)
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

    expect(Rake::Task['infrastructure:provision'].arg_names)
      .to(eq(argument_names))
  end

  it 'cleans the work directory' do
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

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:clean)
            .with(directory: configuration_directory))
  end

  it 'recursively makes the parent of the configuration directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    parent_of_configuration_directory = "#{work_directory}/infra"

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(FileUtils)
      .to(have_received(:mkdir_p)
            .with(parent_of_configuration_directory))
  end

  it 'recursively copies the source directory to the work directory' do
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

    Rake::Task['provision'].invoke

    expect(FileUtils)
      .to(have_received(:cp_r)
            .with(source_directory, configuration_directory))
  end

  it 'switches to the work directory' do
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

    Rake::Task['provision'].invoke

    expect(Dir)
      .to(have_received(:chdir)
            .with(configuration_directory))
  end

  it 'initialises the work directory' do
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

    Rake::Task['provision'].invoke

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

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(no_color: false)))
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

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(no_color: true)))
  end

  it 'passes the provided backend config to init when present' do
    backend_config = {
      bucket: 'some-bucket',
      key: 'some-key.tfstate',
      region: 'eu-west-2'
    }
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backend_config = backend_config
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(
                    backend_config: backend_config
                  )))
  end

  it 'uses the provided backend config factory when supplied' do
    described_class.define(argument_names: [:bucket_name]) do |t, args|
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

    Rake::Task['provision'].invoke('bucket-from-args')

    expect(RubyTerraform)
      .to(have_received(:init)
            .with(hash_including(
                    backend_config: {
                      bucket: 'bucket-from-args',
                      key: 'network.tfstate',
                      region: 'eu-west-2'
                    }
                  )))
  end

  it 'applies terraform for the provided configuration' do
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

    Rake::Task['provision'].invoke

    expect(RubyTerraform).to(have_received(:apply))
  end

  it 'uses the provided source directory factory when supplied' do
    bucket_name = 'bucket-from-args'
    configuration_name = 'network'
    source_directory = "#{bucket_name}/#{configuration_name}"
    configuration_directory = "build/#{bucket_name}/#{configuration_name}"

    described_class.define(argument_names: [:bucket_name]) do |t, args|
      t.configuration_name = configuration_name
      t.source_directory = "#{args.bucket_name}/#{t.configuration_name}"
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke(bucket_name)

    expect(FileUtils)
      .to(have_received(:cp_r)
      .with(source_directory, configuration_directory))
  end

  it 'uses the provided vars map in the terraform apply call' do
    vars = {
      first_thing: '1',
      second_thing: '2'
    }

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.vars = vars
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(vars: vars)))
  end

  it 'uses the provided vars factory in the terraform apply call' do
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

    Rake::Task['provision'].invoke('staging')

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(vars: {
                                   deployment_identifier: 'staging',
                                   configuration_name: 'network',
                                   state_bucket: 'some-bucket'
                                 })))
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

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(var_file: var_file)))
  end

  it 'uses the provided state file when present' do
    state_file = 'some/state.tfstate'

    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.state_file = state_file
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(state: state_file)))
  end

  it 'uses the provided state file factory when present' do
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

    Rake::Task['provision'].invoke('staging')

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(
                    state: 'path/to/state/staging/network.tfstate'
                  )))
  end

  it 'passes an auto_approve parameter of true to apply' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(auto_approve: true)))
  end

  it 'passes a no_color parameter of false to apply by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(no_color: false)))
  end

  it 'passes the provided value for the no_color parameter to apply ' \
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

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(no_color: true)))
  end

  it 'passes a no_backup parameter of false to apply by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(no_backup: false)))
  end

  it 'passes the provided value for the no_backup parameter to apply ' \
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

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(no_backup: true)))
  end

  it 'passes a backup parameter of nil to apply by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(backup: nil)))
  end

  it 'passes the provided backup_file value for the backup parameter to ' \
     'apply when present' do
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

    Rake::Task['provision'].invoke

    expect(RubyTerraform)
      .to(have_received(:apply)
            .with(hash_including(backup: backup_file)))
  end

  def stub_puts
    allow(Kernel).to(receive(:puts))
  end

  def stub_fs
    allow(Dir).to(receive(:chdir)).and_yield
    allow(FileUtils).to(receive(:cp_r))
    allow(FileUtils).to(receive(:mkdir_p))
  end

  def stub_ruby_terraform
    allow(RubyTerraform).to(receive(:clean))
    allow(RubyTerraform).to(receive(:init))
    allow(RubyTerraform).to(receive(:apply))
  end
end
