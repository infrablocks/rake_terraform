require 'logger'
require 'rake_dependencies'
require 'ruby_terraform'
require 'rake_terraform/version'
require 'rake_terraform/tasklib'
require 'rake_terraform/tasks'

require 'logger'

logger = Logger.new(STDERR)
logger.level = Logger.const_get(ENV['RKTF_DEBUG'] || 'WARN')

module RakeTerraform
  include RubyTerraform

  def self.define_command_tasks(&block)
    RakeTerraform::Tasks::All.new(&block)
  end

  def self.define_installation_tasks(opts = {})
    namespace = opts[:namespace] || :terraform
    version = opts[:version] || '0.10.3'
    path = opts[:path] || File.join('vendor', 'terraform')
    providers = opts[:providers] || []

    RubyTerraform.configure do |c|
      c.binary = File.join(path, 'bin', 'terraform')
    end
    RakeDependencies::Tasks::All.new do |t|
      t.namespace = namespace
      t.dependency = 'terraform'
      t.version = version
      t.path = path
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

        logger.debug("Terraform binary is at: #{terraform_binary}")

        if File.exist?(terraform_binary)
          command_line = Lino::CommandLineBuilder.for_command(terraform_binary)
              .with_flag('-version')
              .build

          logger.debug(
              'Fetching terraform version information using command: ' +
                  "#{command_line}")

          command_line.execute(stdout: version_string)

          logger.debug(
              "Terraform version information is: \n#{version_string.string}")

          if version_string.string.lines.first =~ /#{version}/
            return false
          end
        end

        return true
      end
    end
    providers.each do |provider|
      name = provider[:name]
      version = provider[:version]
      path = provider[:path]
      repository = provider[:repository]
      dependency = "terraform-provider-#{name}"

      Rake.application.in_namespace namespace do
        Rake.application.in_namespace :providers do
          RakeDependencies::Tasks::All.new do |t|
            t.namespace = name
            t.dependency = dependency
            t.version = version
            t.path = path
            t.type = :tar_gz

            t.os_ids = {mac: 'darwin', linux: 'linux'}

            t.uri_template =
                "https://github.com/#{repository}/releases/download/" +
                    "<%= @version %>/#{dependency}_v<%= @version %>_" +
                    "<%= @os_id %>_amd64<%= @ext %>"
            t.file_name_template =
                "#{dependency}_v<%= @version %>_<%= @os_id %>_amd64<%= @ext %>"

            t.source_binary_name_template = dependency
            t.target_binary_name_template = "#{dependency}_v<%= @version %>"

            t.installation_directory = "#{ENV['HOME']}/.terraform.d/plugins"

            t.needs_fetch = lambda do |parameters|
              !File.exists?(
                  File.join(
                      parameters[:path],
                      parameters[:binary_directory],
                      "#{dependency}_v#{parameters[:version]}"))
            end
          end
        end
      end
    end
    Rake::Task["#{namespace}:ensure"]
        .enhance(providers.map {|provider|
          "#{namespace}:providers:#{provider[:name]}:ensure"})
  end
end
