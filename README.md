# mime_actor

[![Version][rubygems_badge]][rubygems]
[![CI][ci_badge]][ci_workflows]
[![Coverage][coverage_badge]][coverage]
[![Maintainability][maintainability_badge]][maintainability]

Action processing with Callback + Rescue handlers for different MIME types in Rails.

## Usage

MimeActor allows you to do something like below:
```rb
class EventsController < ActionController::Base
  include MimeActor::Action

  before_act -> { @events = Event.all }, action: :index
  before_act :load_event, action: %i[show update]

  respond_act_to :html, :json, on: :update
  respond_act_to :html, on: %i[index show], with: :render_html
  respond_act_to :json, on: %i[index show], with: -> { render json: { action: action_name } }

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
    render json: @event # render json using #as_json
  end

  def render_html
    @event_categories = EventCategory.all if action_name == :index
    render html: action_name
  end

  def load_event
    @event = Event.find(params.require(:event_id))
  end

  def handle_json_error(error)
    render status: :bad_request, json: { error: error.message }
  end
end
```

Seems useful? See the [Comparison][doc_comparison] on how it can improve your existing code

## Features

- Action customisation for [ActionController][doc_action_controller] per MIME type
- Customisation are deduplicated automatically when configured multiple times
- Flexible rescue handler definition for the combination of Action/MIME type or both
- Built on top of [ActionController::Metal::MimeResponds][doc_action_controller_mime_responds]
- Fully compatible with other [ActionController][doc_action_controller] functionalities 

## Documentation

You can find the documentation on [RubyDoc][doc_mime_actor].

## Requirements

- Ruby: MRI 3.1+
- Rails: 5.0+

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
[ci_badge]: https://github.com/ryancyq/mime_actor/actions/workflows/build.yml/badge.svg
[ci_workflows]: https://github.com/ryancyq/mime_actor/actions/workflows/
[coverage_badge]: https://codecov.io/gh/ryancyq/mime_actor/graph/badge.svg?token=4C091RHXC3
[coverage]: https://codecov.io/gh/ryancyq/mime_actor
[maintainability_badge]: https://api.codeclimate.com/v1/badges/06689606dc3f3945dc1b/maintainability
[maintainability]: https://codeclimate.com/github/ryancyq/mime_actor/maintainability

[doc_mime_actor]: https://rubydoc.info/gems/mime_actor
[doc_action_controller]: https://rubydoc.info/gems/actionpack/ActionController/Metal
[doc_action_controller_mime_responds]: https://rubydoc.info/gems/actionpack/ActionController/MimeResponds
[doc_comparison]: https://github.com/ryancyq/mime_actor/blob/main/COMPARE.md