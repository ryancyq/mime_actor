# frozen_string_literal: true

require_relative "events_active_record"
require "mime_actor"
require "action_controller"

class EventsController < ActionController::Base
  include MimeActor::Action

  act_before -> { @events = Event.all }, action: :index
  act_before :load_event, action: %i[show update]
  act_before -> { @event_categories = EventCategory.all }, action: :show, format: :html

  act_on_action :update, format: %i[html json]
  act_on_action :index, :show, format: :html, with: :render_html
  act_on_action :index, :show, :update, format: :json, with: -> { render json: { action: action_name } }

  act_after -> { redirect_to "/events/#{@event.id}" }, action: :update, format: :html

  rescue_act_from ActiveRecord::RecordNotFound, format: :json, with: :handle_json_error
  rescue_act_from ActiveRecord::RecordNotFound, format: :html, action: :show, with: :handle_update_error_html
  rescue_act_from ActiveRecord::RecordNotFound, format: :html, action: :show, with: -> { redirect_to "/events" }

  def update
    # ...
  end

  private

  def load_event
    @event = Event.find(params.require(:event_id))
  end

  def render_html
    render html: action_name
  end

  def handle_json_error(error)
    render status: :bad_request, json: { error: error.message }
  end

  def handle_update_error_html
    render html: :edit
  end
end
