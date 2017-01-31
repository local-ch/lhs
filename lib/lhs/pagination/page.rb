class LHS::Pagination::Page < LHS::Pagination::Base

  def current_page
    offset
  end

  def next_offset(step = 1)
    current_page + step
  end
end
