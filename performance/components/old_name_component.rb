# frozen_string_literal: true

class Performance::OldNameComponent < ViewComponent::OldBase
  def initialize(name:)
    @name = name
  end
end
