# frozen_string_literal: true

require "bundler/gem_tasks"

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "github_changelog_generator/task"
GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = "ryancyq"
  config.project = "mime_actor"
  config.since_tag = "v0.1.0"
  config.exclude_tags_regex = %r{v[0-9]+\.[0-9]+\.[0-9]+\..+} # pre-releases
end
