# frozen_string_literal: true

require 'active_support'

class LHS::Record

  module Last
    extend ActiveSupport::Concern

    module ClassMethods
      def last(options = nil)
        first_batch = find_by({}, options).parent
        if first_batch.paginated?
          pagination = first_batch._pagination
          find_by({ pagination_key => pagination.class.page_to_offset(pagination.last_page, pagination.limit) }, options)
        else
          first_batch.last
        end
      end

      def last!(options = nil)
        find_by!({}, options)
      end
    end
  end
end
