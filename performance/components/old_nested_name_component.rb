# frozen_string_literal: true

class Performance::OldNestedNameComponent < ViewComponent::OldBase
  def initialize(name:)
    @name = name
  end
end
