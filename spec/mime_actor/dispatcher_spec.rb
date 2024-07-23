# frozen_string_literal: true

require "mime_actor/dispatcher"

RSpec.describe MimeActor::Dispatcher do
  describe "MethodCall" do
    let(:dispatcher) { described_class::MethodCall }

    context "when method name is String" do
      let(:dispatch) { dispatcher.new("my_method") }

      it "is valid" do
        expect(dispatch).to be_a(dispatcher)
      end

      it "stores method name" do
        expect(dispatch.method_name).to eq "my_method"
      end
    end

    context "when method name is Symbol" do
      let(:dispatch) { dispatcher.new(:my_method) }

      it "is valid" do
        expect(dispatch).to be_a(dispatcher)
      end

      it "stores method name" do
        expect(dispatch.method_name).to eq :my_method
      end
    end

    context "when method name is Integer" do
      it "is invalid" do
        expect { dispatcher.new(100) }.to raise_error(ArgumentError, "invalid method name: 100")
      end
    end

    context "with args" do
      let(:dispatch) { dispatcher.new(:my_method, 1, "a", :b) }

      it "is valid" do
        expect(dispatch).to be_a(dispatcher)
      end

      it "stores args" do
        expect(dispatch.args).to contain_exactly(1, "a", :b)
      end
    end

    describe "#call" do
      let(:dispatch) { dispatcher.new(:my_method) }

      it "requires target" do
        expect { dispatch.call }.to raise_error(
          ArgumentError, %r{wrong number of arguments}
        )
      end

      it "requires target responds to the method name" do
        expect { dispatch.call(:stub) }.to raise_error(MimeActor::ActorNotFound, ":my_method not found")
      end

      it "returns callee result" do
        expect(dispatcher.new(:to_s).call(:my_symbol)).to eq "my_symbol"
      end

      context "with additional args" do
        let(:dispatch) { dispatcher.new(:to_sym, "extra") }

        it "truncates the args acceptable by method" do
          expect(dispatch.call("my_string")).to eq :my_string
        end
      end

      context "with method visibility" do
        let(:stub_target_class) { stub_const "StubTarget", Class.new }
        let(:stub_target) { stub_target_class.new }

        before do
          stub_target_class.define_method(:my_public_method) { "public" }
          stub_target_class.define_method(:my_protected_method) { "protected" }
          stub_target_class.instance_eval { protected :my_protected_method }
          stub_target_class.define_method(:my_private_method) { "private" }
          stub_target_class.instance_eval { private :my_private_method }
        end

        %i[public protected private].each do |visibility|
          context "with target's #{visibility} method" do
            let(:dispatch) { dispatcher.new(:"my_#{visibility}_method") }

            it "calls" do
              expect(dispatch.call(stub_target)).to eq visibility.to_s
            end
          end
        end
      end
    end
  end

  describe "InstanceExec" do
    let(:dispatcher) { described_class::InstanceExec }

    context "when block is Proc" do
      let(:dispatch) { dispatcher.new(proc { "something" }) }

      it "is valid" do
        expect(dispatch).to be_a(dispatcher)
      end

      it "stores block" do
        expect(dispatch.block).to be_a(Proc)
      end
    end

    context "when block is Lambda" do
      let(:dispatch) { dispatcher.new(-> { "something" }) }

      it "is valid" do
        expect(dispatch).to be_a(dispatcher)
      end

      it "stores block" do
        expect(dispatch.block).to be_a(Proc)
      end
    end

    context "when block is String" do
      it "is invalid" do
        expect { dispatcher.new("my_proc") }.to raise_error(ArgumentError, "invalid block: \"my_proc\"")
      end
    end

    context "with args" do
      let(:dispatch) { dispatcher.new(proc { "something" }, 1, "a", :b) }

      it "is valid" do
        expect(dispatch).to be_a(dispatcher)
      end

      it "stores args" do
        expect(dispatch.args).to contain_exactly(1, "a", :b)
      end
    end

    describe "#call" do
      let(:dispatch) { dispatcher.new(proc { to_s }) }

      it "requires target" do
        expect { dispatch.call }.to raise_error(
          ArgumentError, %r{wrong number of arguments}
        )
      end

      it "returns callee result" do
        expect(dispatch.call(:my_proc)).to eq "my_proc"
      end

      context "with additional args" do
        let(:dispatch) { dispatcher.new(->(num) { "#{self} received #{num}" }, 11, "extra") }

        it "truncates the args acceptable by method" do
          expect(dispatch.call(:my_lambda)).to eq "my_lambda received 11"
        end
      end
    end
  end

  describe "#build" do
    let(:dispatch) { described_class.build(callable) }

    context "when callable is String" do
      let(:callable) { "my_callable" }

      it "returns MethodCall" do
        expect(dispatch).to be_a(described_class::MethodCall)
      end
    end

    context "when callable is Symbol" do
      let(:callable) { :my_callable }

      it "returns MethodCall" do
        expect(dispatch).to be_a(described_class::MethodCall)
      end
    end

    context "when callable is Proc" do
      let(:callable) { proc { "something" } }

      it "returns InstanceExec" do
        expect(dispatch).to be_a(described_class::InstanceExec)
      end
    end

    context "when callable is Lambda" do
      let(:callable) { -> { "something" } }

      it "returns InstanceExec" do
        expect(dispatch).to be_a(described_class::InstanceExec)
      end
    end

    context "when callable is not supported" do
      let(:callable) { 1000 }

      it "returns nil" do
        expect(dispatch).to be_nil
      end
    end
  end
end
