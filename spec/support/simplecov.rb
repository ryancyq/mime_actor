# frozen_string_literal: true

if ENV["CI"]
  require "simplecov"
  require "simplecov-cobertura"
  SimpleCov.start
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end
