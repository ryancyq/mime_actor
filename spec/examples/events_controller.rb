# frozen_string_literal: true

require_relative "events_active_record"
require "mime_actor"
require "action_controller"

class EventsController < ActionController::Base
  include MimeActor::Action

  before_act -> { @events = Event.all }, action: :index
  before_act :load_event, action: %i[show update]
  before_act -> { @event_categories = EventCategory.all }, action: :show, format: :html

  act_on_action :update, format: %i[html json]
  act_on_action :index, :show, format: :html, with: :render_html
  act_on_action :index, :show, format: :json, with: -> { render json: { action: action_name } }

  rescue_act_from ActiveRecord::RecordNotFound, format: :json, with: :handle_json_error
  rescue_act_from ActiveRecord::RecordNotFound, format: :html, action: :show, with: -> { redirect_to "/events" }

  private

  def update_html
    # ...
    redirect_to "/events/#{@event.id}" # redirect to show upon sucessful update
  rescue ActiveRecord::RecordNotFound
    render html: :edit
  end

  def update_json
    # ...
    render json: @event # render with #to_json
  end

  def render_html
    render html: action_name
  end

  def load_event
    @event = Event.find(params.require(:event_id))
  end

  def handle_json_error(error)
    render status: :bad_request, json: { error: error.message }
  end
end
