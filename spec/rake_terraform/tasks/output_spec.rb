# frozen_string_literal: true

require 'ruby_terraform'
require 'spec_helper'

describe RakeTerraform::Tasks::Output do
  include_context 'with rake'

  before do
    namespace :terraform do
      task :ensure
    end
  end

  it 'adds an output task in the namespace in which it is created' do
    namespace :infrastructure do
      described_class.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:output']).not_to be_nil
  end

  it 'gives the output task a description' do
    namespace :dependency do
      described_class.define(configuration_name: 'network') do |t|
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['dependency:output'].full_comment)
      .to(eq('Output network using terraform'))
  end

  it 'allows the task name to be overridden' do
    namespace :infrastructure do
      described_class.define(name: :output_network) do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task.task_defined?('infrastructure:output_network'))
      .to(be(true))
  end

  it 'allows multiple output tasks to be declared' do
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

    infra1_output = Rake::Task['infra1:output']
    infra2_output = Rake::Task['infra2:output']

    expect(infra1_output).not_to be_nil
    expect(infra2_output).not_to be_nil
  end

  it 'depends on the terraform:ensure task by default' do
    namespace :infrastructure do
      described_class.define do |t|
        t.configuration_name = 'network'
        t.source_directory = 'infra/network'
        t.work_directory = 'build'
      end
    end

    expect(Rake::Task['infrastructure:output'].prerequisite_tasks)
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

    expect(Rake::Task['infrastructure:output'].prerequisite_tasks)
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

    expect(Rake::Task['infrastructure:output'].arg_names)
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

    Rake::Task['output'].invoke

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

    Rake::Task['output'].invoke

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

    Rake::Task['output'].invoke

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

    Rake::Task['output'].invoke

    expect(Dir)
      .to(have_received(:chdir)
            .with(configuration_directory))
  end

  it 'outputs with terraform for the provided configuration directory' do
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

    Rake::Task['output'].invoke

    expect(RubyTerraform).to(have_received(:output))
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

    Rake::Task['output'].invoke(bucket_name)

    expect(FileUtils)
      .to(have_received(:cp_r)
            .with(source_directory, configuration_directory))
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

    Rake::Task['output'].invoke

    expect(RubyTerraform)
      .to(have_received(:output)
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

    Rake::Task['output'].invoke('staging')

    expect(RubyTerraform)
      .to(have_received(:output)
            .with(hash_including(
                    state: 'path/to/state/staging/network.tfstate'
                  )))
  end

  it 'passes a no_color parameter of false to output by default' do
    described_class.define do |t|
      t.configuration_name = 'network'
      t.source_directory = 'infra/network'
      t.work_directory = 'build'
    end

    stub_puts
    stub_fs
    stub_ruby_terraform

    Rake::Task['output'].invoke

    expect(RubyTerraform)
      .to(have_received(:output)
            .with(hash_including(no_color: false)))
  end

  it 'passes the provided value for the no_color parameter to output ' \
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

    Rake::Task['output'].invoke

    expect(RubyTerraform)
      .to(have_received(:output)
            .with(hash_including(no_color: true)))
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
    allow(RubyTerraform).to(receive(:output))
  end
end
