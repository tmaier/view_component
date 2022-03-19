# frozen_string_literal: true

module ViewComponent
  class Renderer < ActionView::Base
    attr_reader :lookup_context, :view_renderer, :view_flow, :virtual_path, :current_template

    def initialize(view_context)
      @view_context = view_context
      @initial_view_context = view_context
      @view_renderer ||= view_context.view_renderer
      @lookup_context = view_context.lookup_context
      @view_flow = view_context.view_flow
      @current_template = nil

      @output_buffer = view_context.output_buffer || ActionView::OutputBuffer.new
    end

    def render_component(component)
      # TODO this is wrong, but it works
      old_virtual_path = @virtual_path
      @virtual_path = component.virtual_path

      old_current_template = @current_template
      @current_template = component

      capture do
        yield @output_buffer
      end
    ensure
      @virtual_path = old_virtual_path
      @current_template = old_current_template
    end

    # TODO don't use stacked output buffer, use delegating buffer?
    def output_buffer=(buf)
      super
      @current_template&.instance_variable_set(:@output_buffer, buf)
    end

    # For VC variants
    def variant
      @lookup_context.variants.first
    end

    def method_missing(method, *args, **kwargs, &block)
      return super unless @view_context.respond_to?(method, true)
      @view_context.send(method, *args, **kwargs, &block)
    end

    def respond_to_missing?(method, all)
      @view_context.respond_to?(method, all)
    end

    def url_options
      controller.url_options
    end

    def controller
      @_controller ||= @view_context.controller
    end

    def request
      @request ||= controller.request if controller.respond_to?(:request)
    end

    def config
      @view_context.config
    end
  end
end
