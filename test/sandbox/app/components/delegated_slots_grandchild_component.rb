# frozen_string_literal: true

class DelegatedSlotsGrandchildComponent < ViewComponent::Base
  include ViewComponent::DelegatedSlots

  delegate_renders_one :header, to: :@parent do |c, *args, **kwargs|
    c.header(*args, **{ **kwargs, color: "blue" })
  end

  delegate_renders_many :items, to: :@parent do |c, *args, **kwargs|
    c.item(*args, **{ **kwargs, color: "yellow" })
  end

  def initialize
    @parent = DelegatedSlotsChildComponent.new
  end
end
