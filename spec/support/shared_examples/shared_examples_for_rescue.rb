# frozen_string_literal: true

require "active_support/core_ext/array/wrap"

RSpec.shared_examples "rescuable error filter accepted" do |error_name|
  let(:error_filters) { Array.wrap(error_filter) }
  let(:rescuable) { klazz.rescue_actor_from(*error_filters, with: :my_handler) }

  it "accepts #{error_name || "the error"}" do
    expect { rescuable }.not_to raise_error

    error_filters.each do |filter|
      expect(klazz.actor_rescuers).to include([filter.name, nil, nil, kind_of(Symbol)])
    end
  end
end

RSpec.shared_examples "rescuable format filter accepted" do |format_name|
  let(:format_filters) { Array.wrap(format_filter) }
  let(:rescuable) { klazz.rescue_actor_from(StandardError, format: format_filters, with: :my_handler) }

  it "accepts #{format_name || "the format"}" do
    expect { rescuable }.not_to raise_error
    expect(klazz.actor_rescuers).to include(["StandardError", format_filters, nil, kind_of(Symbol)])
  end
end

RSpec.shared_examples "rescuable format filter rejected" do |format_name|
  let(:format_filters) { Array.wrap(format_filter) }
  let(:rescuable) { klazz.rescue_actor_from(StandardError, format: format_filters, with: :my_handler) }

  it "rejects #{format_name || "the format"}" do
    expect { rescuable }.to raise_error(ArgumentError, /Unsupported formats:/)
    expect(klazz.actor_rescuers).to be_empty
  end
end

RSpec.shared_examples "rescuable action filter accepted" do |action_name|
  let(:action_filters) { Array.wrap(action_filter) }
  let(:rescuable) { klazz.rescue_actor_from(StandardError, action: action_filters, with: :my_handler) }

  it "accepts #{action_name || "the format"}" do
    expect { rescuable }.not_to raise_error
    expect(klazz.actor_rescuers).to include(["StandardError", nil, action_filters, kind_of(Symbol)])
  end
end

RSpec.shared_examples "rescuable action filter rejected" do |action_name|
  let(:action_filters) { Array.wrap(action_filter) }
  let(:rescuable) { klazz.rescue_actor_from(StandardError, action: action_filters, with: :my_handler) }

  it "accepts #{action_name || "the format"}" do
    expect { rescuable }.to raise_error(ArgumentError, "Action can only be Symbol")
    expect(klazz.actor_rescuers).to be_empty
  end
end

RSpec.shared_examples "rescuable with handler accepted" do |handler_name, handler_type|
  let(:rescuable) { klazz.rescue_actor_from(StandardError, with: handler) }

  it "accepts #{handler_name || "the handler"}" do
    expect { rescuable }.not_to raise_error
    expect(klazz.actor_rescuers).to include(["StandardError", nil, nil, kind_of(handler_type)])
  end
end

RSpec.shared_examples "rescuable with handler rejected" do |handler_name, _handler_type|
  let(:rescuable) { klazz.rescue_actor_from(StandardError, with: handler) }

  it "rejects #{handler_name || "the handler"}" do
    expect { rescuable }.to raise_error(ArgumentError, "Rescue handler can only be Symbol/Proc")
    expect(klazz.actor_rescuers).to be_empty
  end
end

RSpec.shared_examples "rescuable actor handler rescued" do |actor_handler_name|
  include_context "rescuable actor handler"

  it "rescues #{actor_handler_name || "the actor handler"}" do
    expect(rescuable).to eq error_instance
  end
end

RSpec.shared_examples "rescuable actor handler skipped" do |actor_handler_name|
  include_context "rescuable actor handler"

  it "skips #{actor_handler_name || "the actor handler"}" do
    expect(rescuable).to be_nil
  end
end
