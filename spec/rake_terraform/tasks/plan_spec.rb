require 'ruby_terraform'
require 'spec_helper'

describe RakeTerraform::Tasks::Plan do
  include_context :rake

  before(:each) do
    namespace :terraform do
      task :ensure
    end
  end

  it 'adds a plan task in the namespace in which it is created' do
    namespace :infrastructure do
      subject.new do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:plan']).not_to be_nil
  end

  it 'gives the plan task a description' do
    namespace :dependency do
      subject.new do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(rake.last_description).to(eq('Plan network using terraform'))
  end

  it 'allows the task name to be overridden' do
    namespace :infrastructure do
      subject.new(:plan_network) do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:plan_network']).not_to be_nil
  end

  it 'allows multiple plan tasks to be declared' do
    namespace :infra1 do
      subject.new do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    namespace :infra2 do
      subject.new do |t|
        t.configuration_name = 'database'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    infra1_plan = Rake::Task['infra1:plan']
    infra2_plan = Rake::Task['infra2:plan']

    expect(infra1_plan).not_to be_nil
    expect(infra2_plan).not_to be_nil
  end

  it 'depends on the terraform:ensure task by default' do
    namespace :infrastructure do
      subject.new do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:plan'].prerequisite_tasks)
        .to(include(Rake::Task['terraform:ensure']))
  end

  it 'depends on the provided task if specified' do
    namespace :tools do
      namespace :terraform do
        task :ensure
      end
    end

    namespace :infrastructure do
      subject.new do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'

        t.ensure_task = 'tools:terraform:ensure'
      end
    end

    expect(Rake::Task['infrastructure:plan'].prerequisite_tasks)
        .to(include(Rake::Task['tools:terraform:ensure']))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = [:deployment_identifier, :region]

    namespace :infrastructure do
      subject.new do |t|
        t.argument_names = argument_names

        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:plan'].arg_names)
        .to(eq(argument_names))
  end

  it 'cleans the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'recursively makes the parent of the configuration directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    parent_of_configuration_directory = "#{work_directory}/infra"

    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'recursively copies the source directory to the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'switches to the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'initialises the work directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'passes a no_color parameter of false to init by default' do
    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'passes the provided value for the no_color parameter to init when present' do
    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'passes the provided backend config to init when present' do
    backend_config = {
        bucket: 'some-bucket',
        key: 'some-key.tfstate',
        region: 'eu-west-2'
    }
    subject.new do |t|
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

    Rake::Task['plan'].invoke
  end

  it 'uses the provided backend config factory when supplied' do
    subject.new do |t|
      t.argument_names = [:bucket_name]

      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backend_config = lambda do |args, params|
        {
            bucket: args.bucket_name,
            key: "#{params.configuration_name}.tfstate",
            region: 'eu-west-2'
        }
      end
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

    Rake::Task['plan'].invoke('bucket-from-args')
  end

  it 'plans with terraform for the provided configuration directory' do
    source_directory = 'infra/network'
    work_directory = 'build'
    configuration_directory = "#{work_directory}/#{source_directory}"

    subject.new do |t|
      t.configuration_name = 'network'
      t.source_directory = source_directory
      t.work_directory = work_directory
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform).to(receive(:plan))

    Rake::Task['plan'].invoke
  end

  it 'uses the provided vars map in the terraform plan call' do
    vars = {
        first_thing: '1',
        second_thing: '2'
    }

    subject.new do |t|
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

    expect(RubyTerraform)
        .to(receive(:plan)
                .with(hash_including(vars: vars)))

    Rake::Task['plan'].invoke
  end

  it 'uses the provided vars factory in the terraform plan call' do
    subject.new do |t|
      t.argument_names = [:deployment_identifier]

      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.backend_config = {
          bucket: 'some-bucket'
      }

      t.vars = lambda do |args, params|
        {
            deployment_identifier: args.deployment_identifier,
            configuration_name: params.configuration_name,
            state_bucket: params.backend_config[:bucket]
        }
      end
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:plan)
                .with(hash_including(vars: {
                    deployment_identifier: 'staging',
                    configuration_name: 'network',
                    state_bucket: 'some-bucket'
                })))

    Rake::Task['plan'].invoke('staging')
  end

  it 'uses the provided state file when present' do
    state_file = 'some/state.tfstate'

    subject.new do |t|
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
        .to(receive(:plan)
                .with(hash_including(state: state_file)))

    Rake::Task['plan'].invoke
  end

  it 'uses the provided plan file when present' do
    plan_file = 'some/plan.tfplan'

    subject.new do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'

      t.plan_file = plan_file
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:plan)
                .with(hash_including(plan: plan_file)))

    Rake::Task['plan'].invoke
  end

  it 'passes a no_color parameter of false to plan by default' do
    subject.new do |t|
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
        .to(receive(:plan)
                .with(hash_including(no_color: false)))

    Rake::Task['plan'].invoke
  end

  it 'passes the provided value for the no_color parameter to plan when present' do
    subject.new do |t|
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
        .to(receive(:plan)
                .with(hash_including(no_color: true)))

    Rake::Task['plan'].invoke
  end

  it 'passes a destroy parameter of false to plan by default' do
    subject.new do |t|
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
        .to(receive(:plan)
                .with(hash_including(destroy: false)))

    Rake::Task['plan'].invoke
  end

  it 'passes the provided value for the destroy parameter to plan when present' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
      t.destroy = true
    end

    stub_puts
    stub_chdir
    stub_cp_r
    stub_mkdir_p
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:plan)
                .with(hash_including(destroy: true)))

    Rake::Task['plan'].invoke
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
    allow(RubyTerraform).to(receive(:plan))
  end
end
