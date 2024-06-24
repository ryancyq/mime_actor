# frozen_string_literal: true

require_relative "lib/mime_actor/version"

Gem::Specification.new do |spec|
  spec.name     = "mime_actor"
  spec.version  = MimeActor.version
  spec.platform = Gem::Platform::RUBY
  spec.authors  = ["Ryan Chang"]
  spec.email    = ["ryancyq@gmail.com"]

  spec.summary     = "action rendering and rescue with mime type via configuration in actionpack"
  spec.description = ""
  spec.homepage    = "https://github.com/ryancyq/mime_actor"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "allowed_push_host"     => "https://rubygems.org",
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => spec.homepage,
    "changelog_uri"         => "https://github.com/ryancyq/mime_actor/blob/main/CHANGELOG.md"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack", ">= 5.0"
  spec.add_dependency "activesupport", ">= 5.0"
  spec.add_dependency "rake", ">= 11.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
