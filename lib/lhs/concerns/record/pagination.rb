require 'active_support'

class LHS::Record

  module Pagination
    extend ActiveSupport::Concern

    def current_page
      offset / limit + 1
    end

    def first_page
      1
    end

    def last_page
      total_pages
    end

    def prev_page
      current_page - 1
    end

    def next_page
      current_page + 1
    end

    def limit_value
      limit
    end

    def total_pages
      total / limit
    end
  end
end
