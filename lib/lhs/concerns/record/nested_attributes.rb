# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/class/attribute'

class LHS::Record

  module NestedAttributes
    extend ActiveSupport::Concern

    module ClassMethods
      def accepts_nested_attributes_for(*attr_names)
        attr_names.each do |association_name|
          if _relations.keys.include?(association_name)
          else
            raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
          end
        end
      end
    end
  end
end
