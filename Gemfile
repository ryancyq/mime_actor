# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "actionpack", ">= 5.0"
gem "activesupport", ">= 5.0"
gem "rake", ">= 10.0"

group :development, :test do
  gem "rspec", "~> 3.12"
  gem "simplecov", "~> 0.21.2", require: false
  gem "simplecov-cobertura", require: false
end

group :development do
  gem "rubocop", "~> 1.64", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
end
