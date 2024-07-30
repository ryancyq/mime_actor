## Comparison in Rails

When some actions render more than a single MIME type with error handling sfor different MIME type.
```rb
class EventsController < ActionController::Base
  def show
    respond_to do |format|
      format.html { render "show" }
      format.json { render_event_json }
      format.pdf { render_event_pdf }
    end
  end

  def create
    respond_to do |format|
      format.html do
        create_event ? redirect_to "/events/#{@event.id}" : render "create"
      end
      format.json do
        create_event!
        render_event_json
      rescue StandardError => error
        render status: :bad_request, json: { error: error.message }
      end
    end
  end

  def update
    # this will be executed regardless of the requested format.
    # e.g. requesting for xml will execute #update_event but responded with :not_acceptable http status
    success = update_event

    respond_to do |format|
      format.html { success ? redirect_to "/events/#{@event.id}" : render "update" }
      format.json { render_event_json }
    end
  end

  def render_event_json
    render json: @event
  rescue StandardError => e
    render json: { error: e.message }
  end

  def render_event_pdf
    # ...
    # render pdf view or call pdf library with options
  rescue StandardError
    # render error page / redirect to 404 page
  end
end
```

### With MIME Action

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

  act_before -> { @events = Event.all }, action: :index

  # dynamically defines the action method according to on: argument
  act_on_action :index, format: %i[html json]

  act_after :render_index_html, action: :index, format: :html
  act_after -> { render json: @events }, action: :index, format: :json

  def index
    @event_categories = EventCategory.all
  end
  
  def render_index_html
    # render html using @events and @event_categories
    render :index
  end
end
```

### With MIME Rescue

#### before
```rb
class EventsController < ActionController::Base
  before_action :load_event, action: %i[show update]

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

  act_before :load_event, action: %i[show update]

  act_on_action :show, :update, format: :html
  act_on_action :show, :update, format: :json, with: -> { render json: @event } # render json using #as_json

  act_after :render_show_html, action: :show, format: :html
  act_after :redirect_to_show, action: :update, format: :html

  rescue_act_from ActiveRecord::RecordNotFound, format: :json, with: :handle_json_error
  rescue_act_from ActiveRecord::RecordNotFound, format: :html, action: :show do
    redirect_to events_path
  end
  rescue_act_from ActiveRecord::RecrodNotSaved, format: :html, action: :update, with: -> { render :edit }

  def show
    # ...
  end

  def update
    # ...
  end

  private

  def render_show_html
    render :show # render html using @event
  end

  def redirect_to_show
    redirect_to event_path(@event.id) # redirect to show upon sucessful update
  end

  def handle_json_error(error)
    render status: :bad_request, json: { error: error.message }
  end
end
```