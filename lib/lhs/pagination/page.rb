# frozen_string_literal: true

class LHS::Pagination::Page < LHS::Pagination::Base

  DEFAULT_OFFSET = 1

  def current_page
    offset
  end

  def last_page?(response_limit, requested_limit)
    (offset - 1 * requested_limit) + response_limit >= total
  end

  def next_offset(step = 1)
    self.class.next_offset(current_page, limit, step)
  end

  def self.next_offset(current_page, _limit, step = 1)
    current_page.to_i + step.to_i
  end
end
