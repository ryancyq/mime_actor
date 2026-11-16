# frozen_string_literal: true

require "mime_actor"

RSpec.describe MimeActor::Error do
  it "defaults the message to the class name" do
    expect(MimeActor::ActorError.new(:create).message).to eq "MimeActor::ActorError"
  end

  it "inspects with the class name and message" do
    expect(MimeActor::ActorNotFound.new(:create).inspect).to eq "<MimeActor::ActorNotFound> :create not found"
  end
end
