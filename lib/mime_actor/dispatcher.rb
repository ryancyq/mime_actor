# frozen_string_literal: true

# :markup: markdown

module MimeActor
  module Dispatcher
    class MethodCall
      attr_reader :method_name, :args

      def initialize(method_name, *args)
        @method_name = method_name
        @args = args
        validate!
      end

      def to_callable
        lambda do |target|
          throw :abort, method_name unless target.respond_to?(method_name)
          method_call = target.method(method_name)
          filtered_args = method_call.arity.negative? ? args : args.take(method_call.arity)
          method_call.call(*filtered_args)
        end
      end

      private

      def validate!
        raise ArgumentError, "invalid method name: #{method_name.inspect}" unless method_name in String | Symbol
      end
    end

    class InstanceExec
      attr_reader :block, :args

      def initialize(block, *args)
        @block = block
        @args = args
        validate!
      end

      def to_callable
        lambda do |target|
          filtered_args = block.arity.negative? ? args : args.take(block.arity)
          target.instance_exec(*filtered_args, &block)
        end
      end

      private

      def validate!
        raise ArgumentError, "invalid block: #{block.inspect}" unless block in Proc
      end
    end

    def self.build(callable, *args)
      case callable
      when String, Symbol
        MethodCall.new(callable, *args)
      when Proc
        InstanceExec.new(callable, *args)
      end
    end
  end
end
