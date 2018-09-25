require 'logger'
require 'rake_dependencies'
require 'ruby_terraform'
require 'rake_terraform/version'
require 'rake_terraform/tasklib'
require 'rake_terraform/tasks'

module RakeTerraform
  include RubyTerraform

  def self.define_command_tasks(&block)
    RakeTerraform::Tasks::All.new(&block)
  end

  def self.define_installation_tasks(opts = {})
    logger = opts[:logger] ||
        Logger.new(STDERR, level: Logger.const_get(ENV['RKTF_LOG'] || 'WARN'))

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

        logger.info("Terraform binary should be at: #{terraform_binary}")

        if File.exist?(terraform_binary)
          command_line = Lino::CommandLineBuilder.for_command(terraform_binary)
              .with_flag('-version')
              .build

          logger.info(
              'Fetching terraform version information using command: ' +
                  "#{command_line}")

          command_line.execute(stdout: version_string)

          logger.info(
              "Terraform version information is: \n#{version_string.string}")

          version_line = version_string.string.lines.first
          version_is_correct = version_line =~ /#{version}/

          logger.debug(
              "Version: '#{version}' is in version line: '#{version_line}'?: " +
                  "#{version_is_correct}")

          return !version_is_correct
        end

        return true
      end
    end
    providers.each do |provider|
      dependency = "terraform-provider-#{provider[:name]}"

      Rake.application.in_namespace namespace do
        Rake.application.in_namespace :providers do
          RakeDependencies::Tasks::All.new do |t|
            t.namespace = provider[:name]
            t.dependency = dependency
            t.version = provider[:version]
            t.path = provider[:path] || File.join('vendor', dependency)
            t.type = :tar_gz

            t.os_ids = {mac: 'darwin', linux: 'linux'}

            t.uri_template =
                "https://github.com/#{provider[:repository]}/releases/" +
                    "download/<%= @version %>/" +
                    "#{dependency}_v<%= @version %>_<%= @os_id %>" +
                    "_amd64<%= @ext %>"
            t.file_name_template =
                "#{dependency}_v<%= @version %>_<%= @os_id %>_amd64<%= @ext %>"

            t.source_binary_name_template = dependency
            t.target_binary_name_template = "#{dependency}_v<%= @version %>"

            t.installation_directory = "#{ENV['HOME']}/.terraform.d/plugins"

            t.needs_fetch = lambda do |parameters|
              provider_binary = File.join(
                  parameters[:path],
                  parameters[:binary_directory],
                  "#{dependency}_v#{parameters[:version]}")

              logger.info(
                  "Terraform provider binary for: #{provider[:name]} " +
                      "should be at: #{provider_binary}")

              binary_exists = File.exists?(provider_binary)

              logger.debug("Provider file exists?: #{binary_exists}")

              !binary_exists
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
