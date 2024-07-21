# frozen_string_literal: true

require "mime_actor/callbacks"

RSpec.describe MimeActor::Callbacks do
  it_behaves_like "runnable act callbacks", :before
  it_behaves_like "runnable act callbacks", :after
end
