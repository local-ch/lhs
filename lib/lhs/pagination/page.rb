class LHS::Pagination::Page < LHS::Pagination::Base

  def current_page
    offset
  end

  def next_offset(step = 1)
    self.class.next_offset(current_page, limit, step)
  end

  def self.next_offset(current_page, _limit, step = 1)
    current_page.to_i + step.to_i
  end
end
