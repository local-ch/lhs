# frozen_string_literal: true

class LHS::Pagination::Offset < LHS::Pagination::Base

  DEFAULT_OFFSET = 0

  def current_page
    (offset + limit) / limit
  end

  def next_offset(step = 1)
    self.class.next_offset(offset, limit, step)
  end

  def last_page?(response_limit, requested_limit)
    offset + response_limit >= total
  end

  def self.page_to_offset(page, limit = DEFAULT_LIMIT)
    (page.to_i - 1) * limit.to_i
  end

  def self.next_offset(offset, limit, step = 1)
    offset.to_i + limit.to_i * step.to_i
  end
end
