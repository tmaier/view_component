# frozen_string_literal: true

module ViewComponent
  module AliasedSlots
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def alias_renders_one(slot_name, as:)
        singular_name = slot_name.to_s.singularize.to_sym
        singular_alias = as.to_s.singularize.to_sym

        # setter containing with_* prefix
        define_method(:"with_#{singular_alias}") do |*args, &block|
          block.ruby2_keywords if block.respond_to?(:ruby2_keywords, true)
          send(:"with_#{singular_name}", *args, &block)
        end
        if respond_to?(:ruby2_keywords, true)
          send(:ruby2_keywords, :"with_#{singular_alias}")
        end

        # getter/setter combo
        define_method(singular_alias) do |*args, &block|
          block.ruby2_keywords if block.respond_to?(:ruby2_keywords, true)
          # Deprecated: Will remove in 3.0
          send(singular_name, *args, &block)
        end
        send(:ruby2_keywords, singular_alias) if respond_to?(:ruby2_keywords, true)
      end

      def alias_renders_many(slot_name, as:)
        singular_name = slot_name.to_s.singularize.to_sym
        singular_alias = as.to_s.singularize.to_sym
        plural_name = slot_name.to_s.pluralize.to_sym
        plural_alias = as.to_s.pluralize.to_sym

        # setter containing with_* prefix
        define_method(:"with_#{singular_alias}") do |*args, &block|
          block.ruby2_keywords if block.respond_to?(:ruby2_keywords, true)
          send(:"with_#{singular_name}", *args, &block)
        end
        if respond_to?(:ruby2_keywords, true)
          send(:ruby2_keywords, :"with_#{singular_alias}")
        end

        # setter
        define_method(singular_alias) do |*args, &block|
          block.ruby2_keywords if block.respond_to?(:ruby2_keywords, true)
          send(singular_name, *args, &block)
        end

        # getter
        define_method(plural_alias) do
          send(plural_name)
        end
      end
    end
  end
end
