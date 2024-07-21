# frozen_string_literal: true

require "mime_actor"

RSpec::Matchers.define :have_deprecated do |expected_message|
  def supports_value_expectations?
    false
  end

  def supports_block_expectations?
    true
  end

  match do |actual|
    return false unless actual.is_a?(Proc)

    _result, @deprecations = collect_deprecations(MimeActor.deprecator, &actual)
    return false if @deprecations.empty?

    return false if expected_message && @deprecations.none? { |d| values_match?(expected_message, d) }

    true
  end

  match_when_negated do |actual|
    return false unless actual.is_a?(Proc)

    _result, @deprecations = collect_deprecations(MimeActor.deprecator, &actual)
    return false unless @deprecations.empty?

    true
  end

  failure_message do |actual|
    if !actual.is_a?(Proc)
      "expected a deprecation warning but was not given a block"
    elsif @deprecations.empty?
      "expected a deprecation warning within the block but received none"
    elsif expected_message
      "no deprecation warning matched #{expected_message}: #{@deprecations.join(", ")}"
    end
  end

  failure_message_when_negated do |actual|
    if !actual.is_a?(Proc)
      "expected no deprecation warning but was not given a block"
    elsif @deprecations.empty?
      "expected no deprecation warning within the block but received #{@deprecations.size}: \n  #{@deprecations * "\n  "}"
    end
  end

  def collect_deprecations(deprecator)
    old_behavior = deprecator.behavior
    deprecations = []
    deprecator.behavior = proc do |message|
      deprecations << message
    end
    result = yield
    [result, deprecations]
  ensure
    deprecator.behavior = old_behavior
  end
end
