## Comparison in Rails

### MIME Rendering

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

    before_action only: :index { @events = Event.all }

    # dynamically defines the action method according to on: argument
    compose_scene :html, :json, on: :index 

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

### MIME Rescuing

#### before
```rb
class EventsController < ActionController::Base
    # AbstractController::Callbacks here to load model with params
    before_action only: [:show, :update] { @event = Event.find(params.require(:event_id)) }

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
            format.html { redirect_to event_path(@event.id)  } # redirect to show upon sucessful update
            format.json { render json: @event } # render json using #as_json
        end
    end
end
```
#### after
```rb
class EventsController < ActionController::Base
    include MimeActor::Action

    # AbstractController::Callbacks here to load model with params
    before_action only: [:show, :update] { @event = Event.find(params.require(:event_id)) }

    compose_scene :html, :json, on: [:show, :update]

    rescue_actor_from ActiveRecord::RecordNotFound, format: :json do |ex|
        render status: :bad_request, json: { error: ex.message }
    end

    rescue_actor_from ActiveRecord::RecordNotFound, format: :html, action: :show do |ex|
        redirect_to events_path
    end

    def show_html
        render :show # render html using @event
    end

    def update_html
        redirect_to event_path(@event.id) # redirect to show upon sucessful update
    rescue ActiveRecord::RecordNotFound
        render :edit
    end

    def show_json
        render json: @event # render json using #as_json
    end

    def update_json
        # ...
        render json: @event # render json using #as_json
    end
end
```