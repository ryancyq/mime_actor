# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "actionpack", "~> 7.0"
gem "activesupport", "~> 7.0"

group :development, :test do
  gem "rake", ">= 11.0"
  gem "rails", "~> 7.0"
  gem "rspec", "~> 3.12"
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-cobertura", require: false
end

group :development do
  gem "rubocop", "~> 1.65", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
end
