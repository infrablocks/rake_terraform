require 'rake_dependencies'
require 'spec_helper'

RSpec.describe RakeTerraform do
  it "has a version number" do
    expect(RakeTerraform::VERSION).not_to be nil
  end

  it 'includes all the RubyTerraform methods' do
    expect(RakeTerraform)
        .to(respond_to(
                :clean, :get, :apply, :destroy, :remote_config, :output))
  end

  context 'define_installation_tasks' do
    context 'when configuring RubyTerraform' do
      it 'sets the binary using a path of vendor/terraform by default' do
        config = stubbed_ruby_terraform_config

        allow(RakeDependencies::Tasks::All).to(receive(:new))
        expect(RubyTerraform).to(receive(:configure).and_yield(config))

        expect(config)
            .to(receive(:binary=)
                    .with('vendor/terraform/bin/terraform'))

        RakeTerraform.define_installation_tasks
      end

      it 'uses the supplied path when provided' do
        config = stubbed_ruby_terraform_config

        allow(RakeDependencies::Tasks::All).to(receive(:new))
        expect(RubyTerraform).to(receive(:configure).and_yield(config))

        expect(config)
            .to(receive(:binary=)
                    .with('tools/terraform/bin/terraform'))

        RakeTerraform.define_installation_tasks(
            path: 'tools/terraform')
      end
    end

    context 'when instantiating RakeDependencies::Tasks::All' do
      it 'sets the namespace to terraform by default' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:namespace=).with(:terraform))

        RakeTerraform.define_installation_tasks
      end

      it 'uses the supplied namespace when provided' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:namespace=).with(:tools_terraform))

        RakeTerraform.define_installation_tasks(
            namespace: :tools_terraform)
      end

      it 'sets the dependency to terraform' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:dependency=).with('terraform'))

        RakeTerraform.define_installation_tasks
      end

      it 'sets the version to 0.9.0 by default' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:version=).with('0.9.0'))

        RakeTerraform.define_installation_tasks
      end

      it 'uses the supplied version when provided' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:version=).with('0.8.7'))

        RakeTerraform.define_installation_tasks(
            version: '0.8.7')
      end

      it 'uses a path of vendor/terraform by default' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:path=).with('vendor/terraform'))

        RakeTerraform.define_installation_tasks
      end

      it 'uses the supplied path when provided' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:path=).with('tools/terraform'))

        RakeTerraform.define_installation_tasks(
            path: File.join('tools', 'terraform'))
      end

      it 'uses a type of zip' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:type=).with(:zip))

        RakeTerraform.define_installation_tasks
      end

      it 'uses os_ids of darwin and linux' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task)
            .to(receive(:os_ids=)
                    .with({mac: 'darwin', linux: 'linux'}))

        RakeTerraform.define_installation_tasks
      end

      it 'uses the correct URI template' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task)
            .to(receive(:uri_template=)
                    .with('https://releases.hashicorp.com/terraform/' +
                              '<%= @version %>/terraform_<%= @version %>' +
                              '_<%= @os_id %>_amd64<%= @ext %>'))

        RakeTerraform.define_installation_tasks
      end

      it 'uses the correct file name template' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task)
            .to(receive(:file_name_template=)
                    .with('terraform_<%= @version %>_<%= @os_id %>' +
                              '_amd64<%= @ext %>'))

        RakeTerraform.define_installation_tasks
      end

      it 'provides a needs_fetch checker' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyTerraform).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:needs_fetch=))

        RakeTerraform.define_installation_tasks
      end

      # TODO: test needs_fetch more thoroughly
    end
  end

  def stubbed_ruby_terraform_config
    config = double('Config')

    allow(config).to(receive(:binary=))

    config
  end

  def stubbed_rake_dependencies_all_task
    task = double('Task')

    allow(task).to(receive(:namespace=))
    allow(task).to(receive(:dependency=))
    allow(task).to(receive(:version=))
    allow(task).to(receive(:path=))
    allow(task).to(receive(:type=))
    allow(task).to(receive(:os_ids=))
    allow(task).to(receive(:uri_template=))
    allow(task).to(receive(:file_name_template=))
    allow(task).to(receive(:needs_fetch=))

    task
  end
end
