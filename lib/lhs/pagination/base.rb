# Pagination is used to navigate paginateable collections
module LHS::Pagination
  class Base

    DEFAULT_LIMIT = 100

    delegate :_record, to: :data
    attr_accessor :data

    def initialize(data)
      self.data = data
    end

    def total
      data._raw.dig(*_record.total_key) || 0
    end

    # as standard in Rails' ActiveRecord count is not summing up, but using the number provided from data source
    alias count total

    def limit
      data._raw.dig(*_record.limit_key(:body)) || DEFAULT_LIMIT
    end

    def offset
      data._raw.dig(*_record.pagination_key(:body)) || self.class::DEFAULT_OFFSET
    end
    alias current_page offset
    alias start offset

    def pages_left
      total_pages - current_page
    end

    def next_offset(_step = 1)
      raise 'to be implemented in subclass'
    end

    def current_page
      raise 'to be implemented in subclass'
    end

    def first_page
      1
    end

    def last_page
      total_pages
    end

    def next?
      data._raw[:next].present?
    end

    def previous?
      data._raw[:previous].present?
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
      (total.to_f / limit).ceil
    end

    def self.page_to_offset(page, _limit)
      page.to_i
    end
  end
end
