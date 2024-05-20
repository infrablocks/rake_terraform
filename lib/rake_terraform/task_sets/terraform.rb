# frozen_string_literal: true

require 'rake'

module RakeTerraform
  module TaskSets
    # rubocop:disable Metrics/ClassLength

    class Terraform
      def self.define(...)
        new(...).define_on(Rake.application)
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

          platform_os_names: platform_os_names,
          platform_cpu_names: platform_cpu_names,

          uri_template: uri_template,
          file_name_template: file_name_template,

          binary_directory: binary_directory,

          logger: logger,

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

      def platform_os_names
        @platform_os_names ||= {
          darwin: 'darwin',
          linux: 'linux',
          mswin32: 'windows',
          mswin64: 'windows'
        }
      end

      def platform_cpu_names
        @platform_cpu_names ||= {
          x86_64: 'amd64',
          x86: '386',
          x64: 'amd64',
          arm: 'arm',
          arm64: 'arm64',
          aarch64: 'arm64'
        }
      end

      def uri_template
        @uri_template ||=
          'https://releases.hashicorp.com/terraform/<%= @version %>/' \
          'terraform_<%= @version %>_' \
          '<%= @platform_os_name %>_<%= @platform_cpu_name %><%= @ext %>'
      end

      def file_name_template
        @file_name_template ||=
          'terraform_<%= @version %>_' \
          '<%= @platform_os_name %>_<%= @platform_cpu_name %><%= @ext %>'
      end

      def needs_fetch
        @needs_fetch ||= ->(_) { !exists_with_correct_version?(binary) }
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
          "Terraform version information is: \n#{result.string}"
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
