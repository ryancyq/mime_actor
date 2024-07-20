# frozen_string_literal: true

# :markup: markdown

module MimeActor
  module Dispatcher
    class MethodCall
      def initialize(method_name, *args)
        @method_name = method_name
        @args = args
      end

      def to_callable
        lambda do |target|
          throw :abort, MimeActor::ActorNotFound.new(@method_name) unless target.respond_to?(@method_name)
          method_call = target.method(@method_name)
          filtered_args = method_call.arity.negative? ? @args : @args.take(method_call.arity)
          method_call.call(*filtered_args)
        end
      end
    end

    class InstanceExec
      def initialize(proc, *args)
        @proc = proc
        @args = args
      end

      def to_callable
        lambda do |target|
          filtered_args = @proc.arity.negative? ? @args : @args.take(@proc.arity)
          target.instance_exec(*filtered_args, &@proc)
        end
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
