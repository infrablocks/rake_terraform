# frozen_string_literal: true

require 'rake'
require 'tempfile'

module RakeTerraform
  module TaskSets
    # rubocop:disable Metrics/ClassLength

    class Terraform
      def self.define(...)
        new(...).define_on(Rake.application)
      end

      attr_reader :delegate

      def initialize(*args, &)
        @opts = args[0]
        @delegate =
          RakeDependencies::TaskSets::All.new(
            task_set_opts, &
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
          namespace:,
          dependency:,
          version:,
          path:,
          type:,

          platform_os_names:,
          platform_cpu_names:,

          uri_template:,
          file_name_template:,

          binary_directory:,

          logger:,

          needs_fetch:
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
        result = Tempfile.new
        command = version_command(binary)

        log_version_lookup(command)

        command.execute(stdout: result)

        result.rewind
        output = result.read

        log_version_information(output)
        log_check_outcome(output)

        contains_version_number?(output)
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

      def log_version_information(output)
        logger.info(
          "Terraform version information is: \n#{output}"
        )
      end

      def log_check_outcome(output)
        logger.debug(
          "Version: '#{version}' is in version line: " \
          "'#{version_line(output)}'?: #{contains_version_number?(output)}"
        )
      end

      def version_line(output)
        output.lines.first
      end

      def contains_version_number?(output)
        version_line(output) =~ /#{version}/
      end
    end

    # rubocop:enable Metrics/ClassLength
  end
end
