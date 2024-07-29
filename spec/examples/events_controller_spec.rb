# frozen_string_literal: true

require_relative "events_controller"
require "action_dispatch/http/mime_type"

RSpec.describe EventsController do
  let(:controller) { described_class }
  let(:dispatch) { controller.dispatch(action_name, action_request, action_response) }
  let(:env) do
    {
      "REQUEST_METHOD" => request_method,
      "HTTP_ACCEPT"    => request_accept,
      "QUERY_STRING"   => request_params,
      "rack.input"     => "" # TODO: remove me, actionpack < 7.0
    }
  end
  let(:action_request) { ActionDispatch::Request.new(env) }
  let(:action_response) { ActionDispatch::Response.new.tap { |res| res.request = action_request } }
  let(:stub_logger) { instance_double(ActiveSupport::Logger) }

  before do
    described_class.config.logger = stub_logger
  end

  {
    "index"  => { respond: %i[html json], method: "GET" },
    "show"   => { respond: %i[html json], method: "GET", params: "event_id=1" },
    "update" => { respond: %i[html json], method: "POST", params: "event_id=1", status: { html: 302 } }
  }.each do |action, options|
    describe "##{action}" do
      let(:action_name) { action }
      let(:request_method) { options[:method] }
      let(:request_params) { options[:params] }

      options[:respond].each do |mime|
        context "with #{mime}" do
          let(:request_accept) { Mime[mime] }

          it "responds" do
            expect(dispatch).to contain_exactly(
              options.dig(:status, mime) || 200,
              a_hash_including("Content-Type" => %r{#{mime}}),
              kind_of(ActionDispatch::Response::RackBody)
            )
          end
        end
      end
    end
  end

  describe "#show" do
    let(:action_name) { "show" }
    let(:request_method) { "GET" }

    context "with non existed event_id" do
      let(:request_params) { "event_id=100" }

      context "with json" do
        let(:request_accept) { Mime[:json] }

        it "responds bad request" do
          expect(dispatch).to contain_exactly(
            400,
            # http 1.0/1.1 support case insensitive, http 2.0 recomends lower case
            # related issues:
            # https://github.com/puma/puma/issues/3250
            # https://github.com/rails/rails/pull/48437
            a_hash_including("Content-Type" => %r{json}),
            kind_of(ActionDispatch::Response::RackBody)
          )
        end
      end

      context "with html" do
        let(:request_accept) { Mime[:html] }

        it "responds" do
          expect(dispatch).to contain_exactly(
            302,
            a_hash_including("Content-Type" => %r{html}),
            kind_of(ActionDispatch::Response::RackBody)
          )
        end
      end
    end
  end
end
