# mime_actor

[![Version][rubygems_badge]][rubygems]
[![CI][ci_badge]][ci_workflows]
[![Coverage][coverage_badge]][coverage]
[![Maintainability][maintainability_badge]][maintainability]

Action processing with Callback + Rescue handlers for different MIME types in Rails.

In most of the Rails apps, a single `ActionController` is only responsible for rendering a single MIME type. That is usually done by calling `ActionController#respond_to` for each action in the controller.

```rb
class EventsController < ActionController::Base
  def index
    @events = Event.all
    respond_to :json
  end

  def show
    respond_to do |format|
      format.json { render json: @event }
    end
  end
end
```

However, it can be a litte bit messy when some actions render more than a single MIME type with error handling for different MIME type. See [comparison][doc_comparison] to understand more.

## Usage

**Mime Actor** allows you to do something like:

#### Customize Action for certain MIME type
```rb
  act_on_action :index, :show, format: %i[html json]
  act_on_action :create, format: :json

  def index
    @events = Event.all
  end
  def show
    @event = Event.find(params[:id])
  end
  def create
    @event = Event.new.save!
  end
```
The above is equivalent to the following:
```rb
  def index
    respond_to do |format|
      format.html { @events = Event.all }
      format.json { @events = Event.all }
    end
  end
  def show
    respond_to do |format|
      format.html { @event = Event.find(params[:id]) }
      format.json { @event = Event.find(params[:id]) }
    end
  end
  def create
    respond_to do |format|
      format.json { @event = Event.new.save! }
    end
  end
```

#### Callback registration for certain Action + MIME type
```rb
  act_before :load_event_categories, action: :index, format: :html

  act_on_action :index, :show, format: %i[html json]

  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end

  def load_event_categories
    @event_categories = EventCategory.all
  end
```
The above is equivalent to the following:
```rb
  def index
    respond_to do |format|
      format.html do 
        load_event_categories
        @events = Event.all
      end
      format.json { @events = Event.all }
    end
  end

  def show
    respond_to do |format|
      format.html { @event = Event.find(params[:id]) }
      format.json { @event = Event.find(params[:id]) }
    end
  end

  def load_event_categories
    @event_categories = EventCategory.all
  end
```

#### Rescue handler registration for certain Action + MIME type
```rb
  act_before :load_event, action: %i[show update]

  act_on_action :show, :update, format: :json
  act_on_action :show, format: :html

  rescue_act_from ActiveRecord::RecordNotFound, ActiveRecord::RecordNotSaved, format: :json, with: :handle_json_error
  rescue_act_from ActiveRecord::RecordNotSaved, action: :show, format: :html, with: -> { redirect_to "/events" }
  rescue_act_from ActiveRecord::RecordNotSaved, action: :update, format: :html, with: -> { render :edit }

  def show
    # ...
  end

  def update
    @event.name = params[:name]
    @event.save!
    redirect_to "/events/#{@event.id}"
  end

  def load_event
    @event = Event.find(params[:id])
  end

  def handle_json_error(error)
    render status: :bad_request, json: { error: error.message }
  end
```
The above is equivalent to the following:
```rb
  before_action :load_event, only: %i[show update]

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found_error
  rescue_from ActiveRecord::RecordNotSaved, with: :handle_not_saved_error

  def show
    respond_to do |format|
      format.html { ... }
      format.json { ... }
    end
  end

  def update
    @event.name = params[:name]
    @event.save!
    redirect_to "/events/#{@event.id}"
  end

  def handle_not_found_error(error)
    respond_to do |format|
      format.html { redirect_to "/events" }
      format.json { handle_json_error(error) }
    end
  end

  def handle_not_saved_error(error)
    respond_to do |format|
      format.html { render :edit }
      format.json { handle_json_error(error) }
    end
  end

  def handle_json_error(error)
    render status: :bad_request, json: { error: error.message }
  end
```

## Features

- Action customisation for [ActionController][doc_action_controller] per MIME type
- Customisation are deduplicated automatically when configured multiple times
- Flexible rescue handler definition for the combination of Action/MIME type or both
- Built on top of [ActionController::Metal::MimeResponds][doc_action_controller_mime_responds]
- Fully compatible with other [ActionController][doc_action_controller] functionalities 

## Documentation

You can find the documentation on [RubyDoc][doc_mime_actor].

## Requirements

- Ruby: MRI 2.5+
- ActiveSupport: 6.1+
- ActionPack: 6.1+

## Installation

Install the gem and add to the application's Gemfile by executing:
```sh
bundle add mime_actor
```

If bundler is not being used to manage dependencies, install the gem by executing:
```sh
gem install mime_actor
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License
Please see [LICENSE](https://github.com/ryancyq/mime_actor/blob/main/LICENSE) for licensing details.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/ryancyq/mime_actor](https://github.com/ryancyq/mime_actor).

[rubygems_badge]: https://img.shields.io/gem/v/mime_actor.svg
[rubygems]: https://rubygems.org/gems/mime_actor
[ci_badge]: https://github.com/ryancyq/mime_actor/actions/workflows/ci.yml/badge.svg
[ci_workflows]: https://github.com/ryancyq/mime_actor/actions/workflows/ci.yml
[coverage_badge]: https://codecov.io/gh/ryancyq/mime_actor/graph/badge.svg?token=4C091RHXC3
[coverage]: https://codecov.io/gh/ryancyq/mime_actor
[maintainability_badge]: https://api.codeclimate.com/v1/badges/06689606dc3f3945dc1b/maintainability
[maintainability]: https://codeclimate.com/github/ryancyq/mime_actor/maintainability

[doc_mime_actor]: https://rubydoc.info/gems/mime_actor
[doc_action_controller]: https://rubydoc.info/gems/actionpack/ActionController/Metal
[doc_action_controller_mime_responds]: https://rubydoc.info/gems/actionpack/ActionController/MimeResponds
[doc_comparison]: https://github.com/ryancyq/mime_actor/blob/main/COMPARE.md
