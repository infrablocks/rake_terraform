require 'rake/tasklib'
require_relative 'exceptions'

module RakeTerraform
  class TaskLib < ::Rake::TaskLib
    class << self
      def parameter_definitions
        @parameter_definitions ||= {}
      end

      def parameter(name, options = {})
        parameter_definition = ParameterDefinition.new(
            name, options[:default], options[:required])
        name = parameter_definition.name

        attr_accessor(name)

        parameter_definitions[name] = parameter_definition
      end

      def setup_defaults_for(instance)
        parameter_definitions.values.each do |parameter_definition|
          parameter_definition.apply_default_to(instance)
        end
      end

      def check_required_for(instance)
        dissatisfied = parameter_definitions.values.reject do |definition|
          definition.satisfied_by?(instance)
        end
        unless dissatisfied.empty?
          names = dissatisfied.map(&:name)
          raise RequiredParameterUnset,
                "Required parameter#{names.length > 1 ? 's' : ''} #{names.join(',')} unset."
        end
      end
    end

    def initialize(*args, &block)
      setup_defaults
      process_arguments(args)
      process_block(block)
      check_required
      define
    end

    def setup_defaults
      self.class.setup_defaults_for(self)
    end

    def process_arguments(_)
    end

    def process_block(block)
      block.call(self) if block
    end

    def check_required
      self.class.check_required_for(self)
    end

    def define
    end

    private

    class ParameterDefinition
      attr_reader :name

      def initialize(name, default = nil, required = false)
        @name = name.to_sym
        @default = default
        @required = required
      end

      def writer_method
        "#{name}="
      end

      def reader_method
        name
      end

      def apply_default_to(instance)
        instance.__send__(writer_method, @default) unless @default.nil?
      end

      def dissatisfied_by?(instance)
        value = instance.__send__(reader_method)
        @required && value.nil?
      end

      def satisfied_by?(instance)
        !dissatisfied_by?(instance)
      end
    end
  end
end