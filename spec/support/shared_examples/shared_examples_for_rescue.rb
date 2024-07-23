# frozen_string_literal: true

RSpec.shared_examples "rescuable error filter" do |error_name, acceptance: true|
  include_context "with rescuable filter"

  if acceptance
    it "accepts #{error_name || "the error"}" do
      expect { rescuable }.not_to raise_error

      error_filters.each do |filter|
        filter_name = filter.respond_to?(:name) ? filter.name : filter
        expect(klazz.actor_rescuers).to include([filter_name, nil, nil, kind_of(Symbol)])
      end
    end
  else
    it "rejects #{error_name || "the error"}" do
      expect { rescuable }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.actor_rescuers).to be_empty
    end
  end
end

RSpec.shared_examples "rescuable format filter" do |format_name, acceptance: true|
  include_context "with rescuable filter", :format

  if acceptance
    it "accepts #{format_name || "the format"}" do
      expect { rescuable }.not_to raise_error
      error_filters.each do |filter|
        expect(klazz.actor_rescuers).to include([filter.name, format_params, nil, kind_of(Symbol)])
      end
    end
  else
    it "rejects #{format_name || "the format"}" do
      expect { rescuable }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.actor_rescuers).to be_empty
    end
  end
end

RSpec.shared_examples "rescuable action filter" do |action_name, acceptance: true|
  include_context "with rescuable filter", :action

  if acceptance
    it "accepts #{action_name || "the action"}" do
      expect { rescuable }.not_to raise_error
      expect(klazz.actor_rescuers).to include(["StandardError", nil, action_params, kind_of(Symbol)])
    end
  else
    it "accepts #{action_name || "the action"}" do
      expect { rescuable }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.actor_rescuers).to be_empty
    end
  end
end

RSpec.shared_examples "rescuable with handler" do |handler_name, handler_type, acceptance: true|
  let(:rescuable) { klazz.rescue_act_from(StandardError, with: handler) }

  if acceptance
    it "accepts #{handler_name || "the handler"}" do
      expect { rescuable }.not_to raise_error
      expect(klazz.actor_rescuers).to include(["StandardError", nil, nil, kind_of(handler_type)])
    end
  else
    it "rejects #{handler_name || "the handler"}" do
      expect { rescuable }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.actor_rescuers).to be_empty
    end
  end
end

RSpec.shared_examples "rescuable actor handler class method" do |actor_handler_name, acceptance: true|
  include_context "with rescuable actor handler class method"

  if acceptance
    let(:error_instance_rescued) { error_instance }

    it "rescues #{actor_handler_name || "the actor handler"}" do
      expect(rescuable).to eq error_instance_rescued
    end
  else
    it "skips #{actor_handler_name || "the actor handler"}" do
      expect(rescuable).to be_nil
    end
  end
end

RSpec.shared_examples "rescuable actor handler" do |actor_handler_name, acceptance: true|
  include_context "with rescuable actor handler"

  if acceptance
    let(:error_instance_rescued) { error_instance }

    it "rescues #{actor_handler_name || "the actor handler"}" do
      expect(rescuable).to eq error_instance_rescued
    end
  else
    it "skips #{actor_handler_name || "the actor handler"}" do
      expect(rescuable).to be_nil
    end
  end
end
