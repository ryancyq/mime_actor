## Comparison in Rails

### MIME Action

#### before
```rb
class EventsController < ActionController::Base
    def index
        @events = Event.all
        respond_to do |format|
            format.html do
                @event_categories = EventCategory.all

                # render html using @events and @event_categories
                render :index 
            end
            format.json { render json: @events } # render json using #as_json
        end
    end
end
```
#### after
```rb
class EventsController < ActionController::Base
  include MimeActor::Action

  before_act -> { @events = Event.all }, action: :index

  # dynamically defines the action method according to on: argument
  respond_act_to :html, :json, on: :index

  def index_html
      @event_categories = EventCategory.all
      
      # render html using @events and @event_categories
      render :index
  end

  def index_json
      # render json using #as_json
      render json: @events
  end
end
```

### MIME Rescue

#### before
```rb
class EventsController < ActionController::Base
  before_action only: %i[show update], with: :load_event

  rescue_from ActiveRecord::RecordNotFound do |ex|
    case action_name.to_s
    when "show"
      respond_to do |format|
        format.html { redirect_to events_path } # redirect to index
        format.json { render status: :bad_request, json: { error: ex.message } }
      end
    when "update"
      respond_to do |format|
        format.html { render :edit }
        format.json { render status: :bad_request, json: { error: ex.message } }
      end
    else
      raise ex # re-raise since we are not handling it
    end
  end

  def show
    respond_to do |format|
      format.html { render :show } # render html using @event
      format.json { render json: @event } # render json using #as_json
    end
  end

  def update
    # ...
    respond_to do |format|
      format.html { redirect_to event_path(@event.id) } # redirect to show upon sucessful update
      format.json { render json: @event } # render json using #as_json
    end
  end

  private

  def load_event
    @event = Event.find(params.require(:event_id))
  end
end
```
#### after
```rb
class EventsController < ActionController::Base
  include MimeActor::Action

  before_action only: %i[show update], with: :load_event

  respond_act_to :html, on: %i[show update]
  respond_act_to :json, on: %i[show update], with: -> { render json: @event } # render json using #as_json

  rescue_act_from ActiveRecord::RecordNotFound, format: :json, with: :handle_json_error

  rescue_act_from ActiveRecord::RecordNotFound, format: :html, action: :show do
    redirect_to events_path
  end

  private
  
  def show_html
    render :show # render html using @event
  end

  def update_html
    # ...
    redirect_to event_path(@event.id) # redirect to show upon sucessful update
  rescue ActiveRecord::RecordNotFound
    render :edit
  end

  def handle_json_error(error)
    render status: :bad_request, json: { error: error.message }
  end
end
```