# frozen_string_literal: true

class DelegatedSlotsChildComponent < ViewComponent::Base
  include ViewComponent::DelegatedSlots

  delegate_renders_one :header, to: :@parent do |c, *args, **kwargs|
    c.header(*args, **{ color: "red", **kwargs })
  end

  delegate_renders_many :items, to: :@parent do |c, *args, **kwargs|
    c.item(*args, **{ color: "green", **kwargs })
  end

  def initialize
    @parent = DelegatedSlotsParentComponent.new
  end
end
