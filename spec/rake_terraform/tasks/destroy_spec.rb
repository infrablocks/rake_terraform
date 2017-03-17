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
      subject.new do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
      end
    end

    expect(Rake::Task['infrastructure:destroy']).not_to be_nil
  end

  it 'gives the destroy task a description' do
    namespace :dependency do
      subject.new do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
      end
    end

    expect(rake.last_description).to(eq('Destroy network using terraform'))
  end

  it 'allows the task name to be overridden' do
    namespace :infrastructure do
      subject.new(:destroy_network) do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
      end
    end

    expect(Rake::Task['infrastructure:destroy_network']).not_to be_nil
  end

  it 'allows multiple destroy tasks to be declared' do
    namespace :infra1 do
      subject.new do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
      end
    end

    namespace :infra2 do
      subject.new do |t|
        t.configuration_name = 'database'
        t.configuration_directory = 'infra/network'
      end
    end

    infra1_destroy = Rake::Task['infra1:destroy']
    infra2_destroy = Rake::Task['infra2:destroy']

    expect(infra1_destroy).not_to be_nil
    expect(infra2_destroy).not_to be_nil
  end

  it 'depends on the terraform:ensure task by default' do
    namespace :infrastructure do
      subject.new do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
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
      subject.new(:destroy) do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'

        t.ensure_task = 'tools:terraform:ensure'
      end
    end

    expect(Rake::Task['infrastructure:destroy'].prerequisite_tasks)
        .to(include(Rake::Task['tools:terraform:ensure']))
  end

  it 'cleans the terraform state directory' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform).to(receive(:clean))

    Rake::Task['destroy'].invoke
  end

  it 'gets all modules for the provided configuration directory' do
    configuration_directory = 'infra/network'

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = configuration_directory
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:get)
                .with(hash_including(directory: configuration_directory)))

    Rake::Task['destroy'].invoke
  end

  it 'passes a no_color parameter of false to get by default' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:get)
                .with(hash_including(no_color: false)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided value for the no_color parameter to get when present' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
      t.no_color = true
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:get)
                .with(hash_including(no_color: true)))

    Rake::Task['destroy'].invoke
  end

  it 'configures a remote backend with backend config if a backend is provided' do
    backend = 's3'
    backend_config = {
        bucket: 'some-bucket',
        key: 'some-key.tfstate',
        region: 'eu-west-2'
    }
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
      t.backend = backend
      t.backend_config = backend_config
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:remote_config)
                .with(hash_including(
                          backend: backend,
                          backend_config: backend_config)))

    Rake::Task['destroy'].invoke
  end

  it 'passes a no_color parameter of false to remote config by default' do
    backend = 's3'
    backend_config = {
        bucket: 'some-bucket',
        key: 'some-key.tfstate',
        region: 'eu-west-2'
    }
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
      t.backend = backend
      t.backend_config = backend_config
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:remote_config)
                .with(hash_including(no_color: false)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided value for the no_color parameter to remote config when present' do
    backend = 's3'
    backend_config = {
        bucket: 'some-bucket',
        key: 'some-key.tfstate',
        region: 'eu-west-2'
    }
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
      t.backend = backend
      t.backend_config = backend_config
      t.no_color = true
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:remote_config)
                .with(hash_including(no_color: true)))

    Rake::Task['destroy'].invoke
  end

  it 'does not configure a remote backend when no backend is provided' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform).not_to(receive(:remote_config))

    Rake::Task['destroy'].invoke
  end

  it 'destroys with terraform for the provided configuration directory' do
    configuration_directory = 'infra/network'

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = configuration_directory
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(directory: configuration_directory)))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided vars map in the terraform destroy call' do
    vars = {
        first_thing: '1',
        second_thing: '2'
    }

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
      t.vars = vars
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(vars: vars)))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided vars factory in the terraform destroy call' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'

      t.backend = 's3'
      t.backend_config = {
          bucket: 'some-bucket'
      }

      t.vars = lambda do |params|
        {
            configuration_name: params[:configuration_name],
            state_bucket: params[:backend_config][:bucket]
        }
      end
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(vars: {
                    configuration_name: 'network',
                    state_bucket: 'some-bucket'
                })))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided state file when present' do
    state_file = 'some/state.tfstate'

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'

      t.state_file = state_file
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(state: state_file)))

    Rake::Task['destroy'].invoke
  end

  it 'throws an ArgumentError if both backend and state file are provided' do
    expect {
      subject.new do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'

        t.state_file = 'some/state.tfstate'

        t.backend = 's3'
        t.backend_config = {
            bucket: 'some-bucket'
        }
      end
    }.to raise_error(
             ArgumentError,
             "Only one of 'state_file' and 'backend' can be provided.")
  end

  it 'passes a no_color parameter of false to destroy by default' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(no_color: false)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided value for the no_color parameter to destroy when present' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
      t.no_color = true
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(no_color: true)))

    Rake::Task['destroy'].invoke
  end

  it 'passes a no_backup parameter of false to destroy by default' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(no_backup: false)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided value for the no_backup parameter to destroy when present' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'

      t.no_backup = true
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(no_backup: true)))

    Rake::Task['destroy'].invoke
  end

  it 'passes a backup parameter of nil to destroy by default' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(backup: nil)))

    Rake::Task['destroy'].invoke
  end

  it 'passes the provided backup_file value for the backup parameter to destroy when present' do
    backup_file = 'some/state.tfstate.backup'

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'

      t.backup_file = backup_file
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(backup: backup_file)))

    Rake::Task['destroy'].invoke
  end

  it 'passes force as true to destroy' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_puts
    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:destroy)
                .with(hash_including(force: true)))

    Rake::Task['destroy'].invoke
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end

  def stub_ruby_terraform
    allow(RubyTerraform).to(receive(:clean))
    allow(RubyTerraform).to(receive(:get))
    allow(RubyTerraform).to(receive(:remote_config))
    allow(RubyTerraform).to(receive(:destroy))
  end
end
