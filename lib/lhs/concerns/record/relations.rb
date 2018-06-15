require 'active_support'
require 'active_support/core_ext/class/attribute'

class LHS::Record

  module Relations
    extend ActiveSupport::Concern

    included do
      class_attribute :_relations
      self._relations = {}
    end

    module ClassMethods
      def has_many(*options)
        name = options[0]
        options = options[1] || {}
        _relations[name] = { record_class_name: options.fetch(:class_name, name.to_s.singularize.classify) }
      end

      alias has_one has_many
    end
  end
end
