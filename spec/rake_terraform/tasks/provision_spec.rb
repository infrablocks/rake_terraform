require 'ruby_terraform'
require 'spec_helper'

describe RakeTerraform::Tasks::Provision do
  include_context :rake

  it 'adds a provision task in the namespace in which it is created' do
    namespace :infrastructure do
      subject.new do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
      end
    end

    expect(Rake::Task['infrastructure:provision']).not_to be_nil
  end

  it 'gives the provision task a description' do
    namespace :dependency do
      subject.new do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
      end
    end

    expect(rake.last_description).to(eq('Provision network using terraform'))
  end

  it 'allows the task name to be overridden' do
    namespace :infrastructure do
      subject.new(:provision_network) do |t|
        t.configuration_name = 'network'
        t.configuration_directory = 'infra/network'
      end
    end

    expect(Rake::Task['infrastructure:provision_network']).not_to be_nil
  end

  it 'allows multiple provision tasks to be declared' do
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

    infra1_provision = Rake::Task['infra1:provision']
    infra2_provision = Rake::Task['infra2:provision']

    expect(infra1_provision).not_to be_nil
    expect(infra2_provision).not_to be_nil
  end

  it 'cleans the terraform state directory' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_ruby_terraform

    expect(RubyTerraform).to(receive(:clean))

    Rake::Task['provision'].invoke
  end

  it 'gets all modules for the provided configuration directory' do
    configuration_directory = 'infra/network'

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = configuration_directory
    end

    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:get)
                .with(directory: configuration_directory))

    Rake::Task['provision'].invoke
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

    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:remote_config)
                .with(backend: backend, backend_config: backend_config))

    Rake::Task['provision'].invoke
  end

  it 'does not configure a remote backend when no backend is provided' do
    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
    end

    stub_ruby_terraform

    expect(RubyTerraform).not_to(receive(:remote_config))

    Rake::Task['provision'].invoke
  end

  it 'applies terraform for the provided configuration directory' do
    configuration_directory = 'infra/network'

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = configuration_directory
    end

    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:apply)
                .with(hash_including(directory: configuration_directory)))

    Rake::Task['provision'].invoke
  end

  it 'uses the provided vars map in the terraform apply call' do
    vars = {
        first_thing: '1',
        second_thing: '2'
    }

    subject.new do |t|
      t.configuration_name = 'network'
      t.configuration_directory = 'infra/network'
      t.vars = vars
    end

    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:apply)
                .with(hash_including(vars: vars)))

    Rake::Task['provision'].invoke
  end

  it 'uses the provided vars factory in the terraform apply call' do
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

    stub_ruby_terraform

    expect(RubyTerraform)
        .to(receive(:apply)
                .with(hash_including(vars: {
                    configuration_name: 'network',
                    state_bucket: 'some-bucket'
                })))

    Rake::Task['provision'].invoke
  end

  def stub_ruby_terraform
    allow(RubyTerraform).to(receive(:clean))
    allow(RubyTerraform).to(receive(:get))
    allow(RubyTerraform).to(receive(:remote_config))
    allow(RubyTerraform).to(receive(:apply))
  end
end
