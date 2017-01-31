class LHS::Pagination::Offset < LHS::Pagination::Base

  def current_page
    (offset + limit) / limit
  end

  def next_offset(step = 1)
    offset + limit * step
  end

  def self.page_to_offset(page, limit = DEFAULT_LIMIT)
    (page.to_i - 1) * limit.to_i
  end
end
