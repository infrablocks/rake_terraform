# frozen_string_literal: true

require 'rake'

module RakeTerraform
  module TaskSets
    # rubocop:disable Metrics/ClassLength

    class Provider
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
        Rake.application.in_namespace parent_namespace do
          Rake.application.in_namespace :providers do
            @delegate.define_on(application)
          end
        end
        self
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

          source_binary_name_template:,
          target_binary_name_template:,

          installation_directory:,

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

      def name
        @name ||= @opts[:name]
      end

      def repository
        @repository ||= @opts[:repository]
      end

      def parent_namespace
        @parent_namespace ||= @opts[:parent_namespace] || :terraform
      end

      def namespace
        @namespace ||= @opts[:namespace] || name
      end

      def dependency
        @dependency ||= "terraform-provider-#{name}"
      end

      def version
        @version ||= @opts[:version]
      end

      def path
        @path ||= @opts[:path] || File.join('vendor', dependency)
      end

      def binary_directory
        @binary_directory ||= 'bin'
      end

      def binary_name
        @binary_name ||= "#{dependency}_v#{version}"
      end

      def binary
        @binary ||= File.join(path, binary_directory, binary_name)
      end

      def type
        @type ||= :tar_gz
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
          "https://github.com/#{repository}/releases/" \
          'download/<%= @version %>/' \
          "#{dependency}_v<%= @version %>_" \
          '<%= @platform_os_name %>_<%= @platform_cpu_name %><%= @ext %>'
      end

      def file_name_template
        @file_name_template ||=
          "#{dependency}_v<%= @version %>_" \
          '<%= @platform_os_name %>_<%= @platform_cpu_name %><%= @ext %>'
      end

      def source_binary_name_template
        @source_binary_name_template ||= dependency
      end

      def target_binary_name_template
        @target_binary_name_template ||= "#{dependency}_v<%= @version %>"
      end

      def installation_directory
        @installation_directory ||= "#{Dir.home}/.terraform.d/plugins"
      end

      def needs_fetch
        @needs_fetch ||= ->(_) { !exist?(binary) }
      end

      def exist?(binary)
        log_binary_location(binary)

        result = File.exist?(binary)

        log_check_outcome(result)

        result
      end

      def log_binary_location(binary)
        logger.info(
          "Terraform provider binary for: #{name} " \
          "should be at: #{binary}"
        )
      end

      def log_check_outcome(result)
        logger.debug("Provider file exists?: #{result}")
      end
    end

    # rubocop:enable Metrics/ClassLength
  end
end
