# frozen_string_literal: true

require "mime_actor/callbacks"

RSpec.describe MimeActor::Callbacks do
  %i[before after around].each do |kind|
    it_behaves_like "runnable act callbacks", kind

    it_behaves_like "runnable act callbacks action filter", kind, "Nil" do
      let(:action_filter) { nil }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Symbol" do
      let(:action_filter) { :show }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Array of Symbol" do
      let(:action_filter) { %i[show update] }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "String", acceptance: false do
      let(:action_filter) { "index" }
      let(:error_class_raised) { TypeError }
      let(:error_message_raised) { "action must be a Symbol" }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Array of String", acceptance: false do
      let(:action_filter) { %w[index update] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid actions, got: \"index\", \"update\"" }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Array of String/Symbol", acceptance: false do
      let(:action_filter) { [:index, "update"] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid actions, got: \"update\"" }
    end

    it_behaves_like "runnable act callbacks format filter", kind, "Nil" do
      let(:format_filter) { nil }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Symbol" do
      let(:format_filter) { :html }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of Symbol" do
      let(:format_filter) { %i[html json] }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Unsupported format", acceptance: false do
      let(:format_filter) { :something }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid format, got: :something" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of Unsupported format", acceptance: false do
      let(:format_filter) { %i[html something json] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid formats, got: :something" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "String", acceptance: false do
      let(:format_filter) { "json" }
      let(:error_class_raised) { TypeError }
      let(:error_message_raised) { "format must be a Symbol" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of String", acceptance: false do
      let(:format_filter) { %w[html json] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid formats, got: \"html\", \"json\"" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of String/Symbol", acceptance: false do
      let(:format_filter) { [:html, "json"] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid formats, got: \"json\"" }
    end
  end
end
