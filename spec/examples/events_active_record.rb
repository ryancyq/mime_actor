# frozen_string_literal: true

class Event
  def self.all
    []
  end

  def self.find(id)
    raise ActiveRecord::RecordNotFound if id.to_i > 10

    new
  end

  def id
    999
  end
end

class EventCategory
  def self.all
    []
  end
end

module ActiveRecord
  class RecordNotFound < StandardError
  end
end
