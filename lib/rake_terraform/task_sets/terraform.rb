# frozen_string_literal: true

require 'rake'

module RakeTerraform
  module TaskSets
    # rubocop:disable Metrics/ClassLength

    class Terraform
      def self.define(*args, &configuration_block)
        new(*args, &configuration_block).define_on(Rake.application)
      end

      attr_reader :delegate

      def initialize(*args, &configuration_block)
        @opts = args[0]
        @delegate =
          RakeDependencies::TaskSets::All.new(
            task_set_opts, &configuration_block
          )
      end

      def define_on(application)
        @delegate.define_on(application)
        self
      end

      def binary
        @binary ||= File.join(path, binary_directory, binary_name)
      end

      private

      # rubocop:disable Metrics/MethodLength

      def task_set_opts
        {
          namespace: namespace,
          dependency: dependency,
          version: version,
          path: path,
          type: type,

          os_ids: os_ids,

          uri_template: uri_template,
          file_name_template: file_name_template,

          binary_directory: binary_directory,

          needs_fetch: needs_fetch
        }
      end

      # rubocop:enable Metrics/MethodLength

      def logger
        @logger ||=
          @opts[:logger] ||
          Logger.new($stderr,
                     level: Logger.const_get(ENV['TF_LOG'] || 'WARN'))
      end

      def namespace
        @namespace ||= @opts[:namespace] || :terraform
      end

      def dependency
        @dependency ||= 'terraform'
      end

      def version
        @version ||= @opts[:version] || '0.10.3'
      end

      def path
        @path ||= @opts[:path] ||
                  File.join(Dir.pwd, 'vendor', 'terraform')
      end

      def binary_directory
        @binary_directory ||= 'bin'
      end

      def binary_name
        @binary_name ||= 'terraform'
      end

      def type
        @type ||= :zip
      end

      def os_ids
        @os_ids ||= { mac: 'darwin', linux: 'linux' }
      end

      def uri_template
        @uri_template ||=
          'https://releases.hashicorp.com/terraform/<%= @version %>/' \
          'terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>'
      end

      def file_name_template
        @file_name_template ||=
          'terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>'
      end

      def needs_fetch
        @needs_fetch ||= ->(_) { return !exists_with_correct_version?(binary) }
      end

      def exists_with_correct_version?(binary)
        log_binary_location(binary)

        exist?(binary) && correct_version?(binary)
      end

      def exist?(binary)
        File.exist?(binary)
      end

      def correct_version?(binary)
        result = StringIO.new
        command = version_command(binary)

        log_version_lookup(command)

        command.execute(stdout: result)

        log_version_information(result)
        log_check_outcome(result)

        contains_version_number?(result)
      end

      def version_command(binary)
        Lino::CommandLineBuilder
          .for_command(binary)
          .with_flag('-version')
          .build
      end

      def log_binary_location(binary)
        logger.info("Terraform binary should be at: #{binary}")
      end

      def log_version_lookup(command)
        logger.info(
          'Fetching terraform version information using command: ' \
            "#{command}"
        )
      end

      def log_version_information(result)
        logger.info(
          "Terraform version information is: \n#{result}"
        )
      end

      def log_check_outcome(result)
        logger.debug(
          "Version: '#{version}' is in version line: " \
          "'#{version_line(result)}'?: #{contains_version_number?(result)}"
        )
      end

      def version_line(result)
        result.string.lines.first
      end

      def contains_version_number?(result)
        version_line(result) =~ /#{version}/
      end
    end

    # rubocop:enable Metrics/ClassLength
  end
end
