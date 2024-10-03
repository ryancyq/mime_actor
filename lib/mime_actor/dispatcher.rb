# frozen_string_literal: true

# :markup: markdown

require "mime_actor/errors"

module MimeActor
  module Dispatcher
    class MethodCall
      attr_reader :method_name, :args

      def initialize(method_name, *args)
        @method_name = method_name
        @args = args
        validate!
      end

      def call(target)
        raise MimeActor::ActorNotFound, method_name unless target.respond_to?(method_name, true)

        method_call = target.method(method_name)
        filtered_args = method_call.arity.negative? ? args : args.take(method_call.arity)
        method_call.call(*filtered_args)
      end

      private

      def validate!
        return if method_name.is_a?(String) || method_name.is_a?(Symbol)

        raise ArgumentError, "invalid method name: #{method_name.inspect}"
      end
    end

    class InstanceExec
      attr_reader :block, :args

      def initialize(block, *args)
        @block = block
        @args = args
        validate!
      end

      def call(target)
        filtered_args = block.arity.negative? ? args : args.take(block.arity)
        target.instance_exec(*filtered_args, &block)
      end

      private

      def validate!
        raise ArgumentError, "invalid block: #{block.inspect}" unless block.is_a?(Proc)
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
