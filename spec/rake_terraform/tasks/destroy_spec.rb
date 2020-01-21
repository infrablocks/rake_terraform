require 'ruby_terraform'
require 'spec_helper'

describe RakeTerraform::Tasks::Destroy do
  include_context :rake

  before(:each) do
    namespace :terraform do
      task :ensure
    end
  end

  it 'adds a destroy task in the namespace in which it is created' do
    namespace :infrastructure do
      subject.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:destroy']).not_to be_nil
  end

  it 'gives the destroy task a description' do
    namespace :dependency do
      subject.define(configuration_name: 'network') do |t|
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task["dependency:destroy"].full_comment)
        .to(eq('Destroy network using terraform'))
  end

  it 'allows the task name to be overridden' do
    namespace :infrastructure do
      subject.define(
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
      subject.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    namespace :infra2 do
      subject.define do |t|
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
      subject.define do |t|
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
      subject.define(
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
    argument_names = [:deployment_identifier, :region]

    namespace :infrastructure do
      subject.define(argument_names: argument_names) do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:destroy'].arg_names)
        .to(eq(argument_names))
  end

  it 'cleans the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform).to(receive(:clean))
        .with(directory: configuration_directory)

    Rake::Task['destroy'].invoke
  end

  it 'recursively makes the parent of the configuration directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    parent_of_configuration_directory = "#{work_directory}/infra"

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect_any_instance_of(FileUtils)
        .to(receive(:mkdir_p))
        .with(parent_of_configuration_directory, anything)

    Rake::Task['destroy'].invoke
  end

  it 'recursively copies the source directory to the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect_any_instance_of(FileUtils)
        .to(receive(:cp_r))
        .with(source_directory, configuration_directory, anything)

    Rake::Task['destroy'].invoke
  end

  it 'switches to the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(Dir).to(receive(:chdir)).with(configuration_directory).and_yield

    Rake::Task['destroy'].invoke
  end

  it 'initialises the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform).to(receive(:init))

    Rake::Task['destroy'].invoke
  end

  it 'passes a no_color parameter of false to init by default' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:init)
            .with(hash_including(no_color: false)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided value for the no_color parameter to init when present' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.no_color = true
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:init)
            .with(hash_including(no_color: true)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided backend config to init when present' do
    backend_config = {
        bucket: 'some-bucket',
        key: 'some-key.tfstate',
        region: 'eu-west-2'
    }
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backend_config = backend_config
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:init)
            .with(hash_including(
                backend_config: backend_config)))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided backend config factory when supplied' do
    subject.define(argument_names: [:bucket_name]) do |t, args|
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
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:init)
            .with(hash_including(
                backend_config: {
                    bucket: 'bucket-from-args',
                    key: 'network.tfstate',
                    region: 'eu-west-2'
                })))

    Rake::Task['destroy'].invoke('bucket-from-args')
  end

  it 'destroys with terraform for the provided configuration' do
    source_directory = 'infra/network'
    work_directory = 'build'

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform).to(receive(:destroy))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided source directory factory when supplied' do
    bucket_name = 'bucket-from-args'
    configuration_name = 'network'
    source_directory = "#{bucket_name}/#{configuration_name}"
    configuration_directory = "build/#{bucket_name}/#{configuration_name}"

    subject.define(argument_names: [:bucket_name]) do |t, args|
      t.configuration_name = configuration_name
      t.source_directory = "#{args.bucket_name}/#{t.configuration_name}"
      t.work_directory = 'build'
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect_any_instance_of(FileUtils)
        .to(receive(:cp_r))
        .with(source_directory, configuration_directory, anything)

    Rake::Task['destroy'].invoke(bucket_name)
  end

  it 'uses the provided vars map in the terraform destroy call' do
    vars = {
        first_thing: '1',
        second_thing: '2'
    }

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.vars = vars
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(Dir).to(receive(:chdir).and_yield)
    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(vars: vars)))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided vars factory in the terraform destroy call' do
    subject.define(argument_names: [:deployment_identifier]) do |t, args|
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
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(vars: {
                deployment_identifier: 'staging',
                configuration_name: 'network',
                state_bucket: 'some-bucket'
            })))

    Rake::Task['destroy'].invoke('staging')
  end

  it 'uses the provided var file when present' do
    var_file = 'some/terraform.tfvars'

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.var_file = var_file
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(var_file: var_file)))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided state file when present' do
    state_file = 'some/state.tfstate'

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.state_file = state_file
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(state: state_file)))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided state file factory when present' do
    subject.define(argument_names: [:deployment_identifier]) do |t, args|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.state_file =
          "path/to/state/#{args.deployment_identifier}/" +
              "#{t.configuration_name}.tfstate"
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(
                state: "path/to/state/staging/network.tfstate")))

    Rake::Task['destroy'].invoke('staging')
  end

  it 'passes a no_color parameter of false to destroy by default' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(no_color: false)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided value for the no_color parameter to destroy when present' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.no_color = true
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(no_color: true)))

    Rake::Task['destroy'].invoke
  end

  it 'passes a no_backup parameter of false to destroy by default' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(no_backup: false)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided value for the no_backup parameter to destroy when present' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.no_backup = true
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(no_backup: true)))

    Rake::Task['destroy'].invoke
  end

  it 'passes a backup parameter of nil to destroy by default' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(backup: nil)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided backup_file value for the backup parameter to destroy when present' do
    backup_file = 'some/state.tfstate.backup'

    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backup_file = backup_file
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(backup: backup_file)))

    Rake::Task['destroy'].invoke
  end

  it 'passes force as true to destroy' do
    subject.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
            .with(hash_including(force: true)))

    Rake::Task['destroy'].invoke
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end

  def stub_chdir
    allow(Dir).to(receive(:chdir)).and_yield
  end

  def stub_cp_r
    allow_any_instance_of(FileUtils).to(receive(:cp_r))
  end

  def stub_mkdir_p
    allow_any_instance_of(FileUtils).to(receive(:mkdir_p))
  end

  def stub_ruby_terraform
    allow(RubyTerraform).to(receive(:clean))
    allow(RubyTerraform).to(receive(:init))
    allow(RubyTerraform).to(receive(:destroy))
  end
end
