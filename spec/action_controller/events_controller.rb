# frozen_string_literal: true

require "mime_actor"
require "active_record"
require "action_controller"

class EventsController < ActionController::Base
  include MimeActor::Action

  class Event
    def self.all
      []
    end

    def self.find(_id)
      nil
    end
  end

  class EventCategory
    def self.all
      []
    end
  end

  # AbstractController::Callbacks here to load model with params
  before_action only: :index, with: :load_events
  before_action only: %i[show update], with: :load_event

  respond_act_to :html, :json, on: :update
  respond_act_to :html, on: %i[index show], with: :render_html
  respond_act_to :json, on: %i[index show], with: -> { render json: { action: action_name } }

  rescue_act_from ActiveRecord::RecordNotFound, format: :json, with: :handle_json_error

  rescue_act_from ActiveRecord::RecordNotFound, format: :html, action: :show do
    redirect_to "/events"
  end

  def render_html
    @event_categories = EventCategory.all if action_name == :index
    render html: action_name
  end

  def update_html
    # ...
    redirect_to "/events/#{@event_id}" # redirect to show upon sucessful update
  rescue ActiveRecord::RecordNotFound
    render html: :edit
  end

  def update_json
    # ...
    render json: @event # render json using #as_json
  end

  private

  def load_events
    @events = Event.all
  end

  def load_event
    @event = Event.find(params.require(:event_id))
  end

  def handle_json_error(_error)
    render status: :bad_request, json: { error: ex.message }
  end
end
