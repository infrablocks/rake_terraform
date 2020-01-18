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

  context 'define_command_tasks' do
    context 'when instantiating RakeTerraform::Tasks::All' do
      it 'passes the provided block' do
        block = lambda do |t|
          t.configuration_name = 'network'
          t.configuration_directory = 'infra/network'
        end

        expect(RakeTerraform::Tasks::All)
            .to(receive(:new) do |*_, &passed_block|
              expect(passed_block).to(eq(block))
            end)

        RakeTerraform.define_command_tasks(&block)
      end
    end
  end

  context 'define_installation_tasks' do
    context 'when configuring RubyTerraform' do
      it 'sets the binary using a path of `pwd`/vendor/terraform by default' do
        RakeTerraform.define_installation_tasks

        expect(RubyTerraform.configuration.binary)
            .to(eq("#{Dir.pwd}/vendor/terraform/bin/terraform"))
      end

      it 'uses the supplied path when provided' do
        RakeTerraform.define_installation_tasks(
            path: 'tools/terraform')

        expect(RubyTerraform.configuration.binary)
            .to(eq('tools/terraform/bin/terraform'))
      end
    end

    context 'when setting up tasks for terraform installation' do
      it 'sets the namespace to terraform by default' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.namespace).to(eq("terraform"))
      end

      it 'uses the supplied namespace when provided' do
        task_set, _ = RakeTerraform.define_installation_tasks(
            namespace: :tools_terraform)

        expect(task_set.namespace).to(eq("tools_terraform"))
      end

      it 'sets the dependency to terraform' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.dependency).to(eq("terraform"))
      end

      it 'sets the version to 0.10.3 by default' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.version).to(eq("0.10.3"))
      end

      it 'uses the supplied version when provided' do
        task_set, _ = RakeTerraform.define_installation_tasks(
            version: '0.10.4')

        expect(task_set.version).to(eq("0.10.4"))
      end

      it 'uses a path of `pwd`/vendor/terraform by default' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.path).to(eq("#{Dir.pwd}/vendor/terraform"))
      end

      it 'uses the supplied path when provided' do
        task_set, _ = RakeTerraform.define_installation_tasks(
            path: File.join('tools', 'terraform'))

        expect(task_set.path).to(eq(File.join('tools', 'terraform')))
      end

      it 'uses a type of zip' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.type).to(eq(:zip))
      end

      it 'uses os_ids of darwin and linux' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.os_ids).to(eq({mac: 'darwin', linux: 'linux'}))
      end

      it 'uses the correct URI template' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.uri_template)
            .to(eq('https://releases.hashicorp.com/terraform/' +
                '<%= @version %>/terraform_<%= @version %>' +
                '_<%= @os_id %>_amd64<%= @ext %>'))
      end

      it 'uses the correct file name template' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.file_name_template)
            .to(eq('terraform_<%= @version %>_<%= @os_id %>' +
                '_amd64<%= @ext %>'))
      end

      # TODO: test needs_fetch more thoroughly
      it 'provides a needs_fetch checker' do
        task_set, _ = RakeTerraform.define_installation_tasks

        expect(task_set.needs_fetch).not_to(be_nil)
      end
    end

    context 'when providers are supplied' do
      it 'defines dependency tasks for each provider' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                },
                {
                    name: 'something2',
                    path: File.join(
                        'vendor', 'terraform-provider-something2'),
                    version: '1.1.2',
                    repository: 'example/repository2'
                }
            ]
        })

        expect(provider_task_sets[0].dependency)
            .to(eq('terraform-provider-something1'))
        expect(provider_task_sets[1].dependency)
            .to(eq('terraform-provider-something2'))
      end

      it 'adds provider ensure tasks as prerequisites for the terraform ' +
          'ensure task' do
        RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                },
                {
                    name: 'something2',
                    path: File.join(
                        'vendor', 'terraform-provider-something2'),
                    version: '1.1.2',
                    repository: 'example/repository2'
                }
            ]
        })

        expect(Rake::Task["terraform:ensure"].prerequisites).to(include(
            'terraform:providers:something1:ensure',
            'terraform:providers:something2:ensure'
        ))
      end

      it 'uses the provided provider name as the namespace' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].namespace).to(eq("something1"))
      end

      it 'uses the provided provider version as the version' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].version).to(eq("1.1.1"))
      end

      it 'uses the provided provider path as the path' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].path)
            .to(eq(File.join('vendor', 'terraform-provider-something1')))
      end

      it 'defaults the path when none provided' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].path)
            .to(eq(File.join('vendor', 'terraform-provider-something1')))
      end

      it 'uses a type of :tar_gz' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].type).to(eq(:tar_gz))
      end

      it 'passes the correct OS IDs for golang binary defaults' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].os_ids)
            .to(eq({mac: 'darwin', linux: 'linux'}))
      end

      it 'constructs a github release URL based on the provided repository ' +
          'and name' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].uri_template)
            .to(eq("https://github.com/example/repository1/releases/" +
                "download/<%= @version %>/" +
                "terraform-provider-something1_v<%= @version %>_" +
                "<%= @os_id %>_amd64<%= @ext %>"))
      end

      it 'constructs a file name template based on the provided name' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].file_name_template)
            .to(eq("terraform-provider-something1_v<%= @version %>_" +
                "<%= @os_id %>_amd64<%= @ext %>"))
      end

      it 'passes source and target binary name templates' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].source_binary_name_template)
            .to(eq("terraform-provider-something1"))
        expect(provider_task_sets[0].target_binary_name_template)
            .to(eq("terraform-provider-something1_v<%= @version %>"))
      end

      it 'passes the correct installation directory' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].installation_directory)
            .to(eq("#{ENV['HOME']}/.terraform.d/plugins"))
      end

      # TODO: test needs_fetch more thoroughly
      it 'provides a needs_fetch checker' do
        _, provider_task_sets = RakeTerraform.define_installation_tasks({
            providers: [
                {
                    name: 'something1',
                    path: File.join(
                        'vendor', 'terraform-provider-something1'),
                    version: '1.1.1',
                    repository: 'example/repository1'
                }
            ]
        })

        expect(provider_task_sets[0].needs_fetch).not_to(be_nil)
      end
    end
  end
end
