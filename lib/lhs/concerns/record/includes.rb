require 'active_support'

class LHS::Record

  module Includes
    extend ActiveSupport::Concern

    included do
      cattr_accessor :including, :referencing
    end

    module ClassMethods
      def includes(*args)
        class_clone_factory(args).tap do |class_clone|
          class_clone.including = unfold_args(args)
        end
      end

      def references(*args)
        class_clone_factory(args).tap do |class_clone|
          class_clone.referencing = unfold_args(args)
        end
      end

      def without_including
        class_clone_factory(rand.to_s.gsub(/\D/, '')).tap do |class_clone|
          class_clone.including = nil
        end
      end

      private

      def unfold_args(args)
        args.size == 1 ? args[0] : args
      end

      def class_clone_factory(args)
        name = "#{self}#{args.object_id}"
        constant = Object.const_set(name.demodulize, self.dup) # rubocop:disable Style/RedundantSelf
        class_clone = constant
        class_clone.endpoints = endpoints
        class_clone.mapping = mapping
        class_clone
      end
    end
  end
end
