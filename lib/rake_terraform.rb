require 'rake_dependencies'
require 'rake_terraform/version'
require 'rake_terraform/tasklib'
require 'rake_terraform/tasks'

module RakeTerraform
  include RubyTerraform

  def self.define_command_tasks(&block)
    RakeTerraform::Tasks::All.new(&block)
  end

  def self.define_installation_tasks(opts = {})
    RubyTerraform.configure do |c|
      c.binary = File.join(
          opts[:path] || File.join('vendor', 'terraform'),
          'bin', 'terraform')
    end
    RakeDependencies::Tasks::All.new do |t|
      t.namespace = opts[:namespace] || :terraform
      t.dependency = 'terraform'
      t.version = opts[:version] || '0.9.0'
      t.path = opts[:path] || File.join('vendor', 'terraform')
      t.type = :zip

      t.os_ids = {mac: 'darwin', linux: 'linux'}

      t.uri_template =
          'https://releases.hashicorp.com/terraform/<%= @version %>/' +
              'terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>'
      t.file_name_template =
          'terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>'

      t.needs_fetch = lambda do |parameters|
        terraform_binary = File.join(
            parameters[:path],
            parameters[:binary_directory],
            'terraform')
        version_string = StringIO.new

        if File.exist?(terraform_binary)
          Lino::CommandLineBuilder.for_command(terraform_binary)
              .with_flag('-version')
              .build
              .execute(stdout: version_string)

          if version_string.string.lines.first =~ /#{version}/
            return false
          end
        end

        return true
      end
    end
  end
end
