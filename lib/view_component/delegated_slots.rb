# frozen_string_literal: true

module ViewComponent
  module DelegatedSlots
    def self.included(base)
      base.include(InstanceMethods)
      base.extend(ClassMethods)
    end

    module InstanceMethods
      private

      def get_delegated_slot(slot_name, target)
        content unless content_evaluated? # ensure content is loaded so slots will be defined

        target_obj = instance_eval(target.to_s)
        target_obj.send(slot_name)
      end

      def set_delegated_slot(slot_name, target, *args, block, delegated_slot_block)
        target_obj = instance_eval(target.to_s)
        return target_obj.send(slot_name, *args, &block) unless delegated_slot_block

        delegated_slot_block.call(target_obj, *args, &block)
      end
      ruby2_keywords(:set_delegated_slot) if respond_to?(:ruby2_keywords, true)
    end

    module ClassMethods
      def delegate_renders_one(slot_name, to:, &block)
        define_delegated_slot(slot_name, to, collection: false, &block)
      end

      def delegate_renders_many(slot_name, to:, &block)
        define_delegated_slot(slot_name, to, collection: true, &block)
      end

      private

      def define_delegated_slot(slot_name, target, collection:, &delegated_slot_block)
        delegated_slot_block.ruby2_keywords if delegated_slot_block.respond_to?(:ruby2_keywords, true)

        singular_name = slot_name.to_s.singularize.to_sym
        plural_name = slot_name.to_s.pluralize.to_sym

        # collection/non-collection setter containing with_* prefix
        define_method(:"with_#{singular_name}") do |*args, &block|
          block.ruby2_keywords if block.respond_to?(:ruby2_keywords, true)
          set_delegated_slot(singular_name, target, *args, block, delegated_slot_block)
        end
        if respond_to?(:ruby2_keywords, true)
          send(:ruby2_keywords, :"with_#{singular_name}")
        end

        if collection
          # collection setter
          # Deprecated: Will remove in 3.0
          define_method(singular_name) do |*args, &block|
            block.ruby2_keywords if block.respond_to?(:ruby2_keywords, true)
            set_delegated_slot(singular_name, target, *args, block, delegated_slot_block)
          end

          # collection getter
          # Deprecated: Will remove in 3.0
          define_method(plural_name) do
            get_delegated_slot(plural_name, target)
          end
        else
          # non-collection getter/setter combo
          # Deprecated: Will remove in 3.0
          define_method(singular_name) do |*args, &block|
            if args.empty? && block.nil?
              get_delegated_slot(singular_name, target)
            else
              block.ruby2_keywords if block.respond_to?(:ruby2_keywords, true)
              set_delegated_slot(singular_name, target, *args, block, delegated_slot_block)
            end
          end
        end
        send(:ruby2_keywords, singular_name) if respond_to?(:ruby2_keywords, true)
      end
    end
  end
end
