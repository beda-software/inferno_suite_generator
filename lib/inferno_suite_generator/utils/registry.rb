# frozen_string_literal: true

module Registry
  def self.store
    @store ||= {}
  end

  def self.register(key, value)
    store[key] = value
  end

  def self.get(key)
    store[key]
  end
end
