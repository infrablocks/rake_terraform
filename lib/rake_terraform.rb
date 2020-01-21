require 'logger'
require 'rake_dependencies'
require 'ruby_terraform'
require 'rake_terraform/version'
require 'rake_terraform/tasks'
require 'rake_terraform/task_sets'

module RakeTerraform
  include RubyTerraform

  def self.define_command_tasks(opts = {}, &block)
    RakeTerraform::TaskSets::All.define(opts, &block)
  end

  def self.define_installation_tasks(opts = {})
    logger = opts[:logger] ||
        Logger.new(STDERR, level: Logger.const_get(ENV['TF_LOG'] || 'WARN'))

    namespace = opts[:namespace] || :terraform
    version = opts[:version] || '0.10.3'
    path = opts[:path] || File.join(Dir.pwd, 'vendor', 'terraform')
    providers = opts[:providers] || []

    command_task_set_opts = {
        namespace: namespace,
        dependency: 'terraform',
        version: version,
        path: path,
        type: :zip,

        os_ids: {mac: 'darwin', linux: 'linux'},

        uri_template:
            'https://releases.hashicorp.com/terraform/<%= @version %>/' +
                'terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>',
        file_name_template:
            'terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>',

        needs_fetch: lambda { |params|
          terraform_binary = File.join(
              params.path, params.binary_directory, 'terraform')
          version_string = StringIO.new

          logger.info("Terraform binary should be at: #{terraform_binary}")

          if File.exist?(terraform_binary)
            command_line = Lino::CommandLineBuilder
                .for_command(terraform_binary)
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
                "Version: '#{version}' is in version line: " +
                    "'#{version_line}'?: #{version_is_correct}")

            return !version_is_correct
          end

          return true
        }
    }

    RubyTerraform.configure do |c|
      c.binary = File.join(path, 'bin', 'terraform')
    end

    command_task_set = RakeDependencies::TaskSets::All
        .define(command_task_set_opts)

    provider_task_sets = providers.map do |provider|
      dependency = "terraform-provider-#{provider[:name]}"
      provider_task_set_opts = {
          namespace: provider[:name],
          dependency: dependency,
          version: provider[:version],
          path: provider[:path] || File.join('vendor', dependency),
          type: :tar_gz,

          os_ids: {mac: 'darwin', linux: 'linux'},

          uri_template:
              "https://github.com/#{provider[:repository]}/releases/" +
                  "download/<%= @version %>/" +
                  "#{dependency}_v<%= @version %>_<%= @os_id %>" +
                  "_amd64<%= @ext %>",
          file_name_template:
              "#{dependency}_v<%= @version %>_<%= @os_id %>_amd64<%= @ext %>",

          source_binary_name_template: dependency,
          target_binary_name_template: "#{dependency}_v<%= @version %>",

          installation_directory: "#{ENV['HOME']}/.terraform.d/plugins",

          needs_fetch: lambda { |params|
            provider_binary = File.join(
                params.path,
                params.binary_directory,
                "#{dependency}_v#{params.version}")

            logger.info(
                "Terraform provider binary for: #{provider.name} " +
                    "should be at: #{provider_binary}")

            binary_exists = File.exists?(provider_binary)

            logger.debug("Provider file exists?: #{binary_exists}")

            !binary_exists
          }
      }

      provider_task_set = RakeDependencies::TaskSets::All.new(
          provider_task_set_opts)

      Rake.application.in_namespace namespace do
        Rake.application.in_namespace :providers do
          provider_task_set.define_on(Rake.application)
        end
      end

      provider_task_set
    end

    Rake::Task["#{namespace}:ensure"]
        .enhance(providers.map { |provider|
          "#{namespace}:providers:#{provider[:name]}:ensure" })

    return command_task_set, provider_task_sets
  end
end
