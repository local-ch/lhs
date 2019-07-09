# frozen_string_literal: true

class LHS::Pagination::Link < LHS::Pagination::Base
  def total
    data._raw.dig(*_record.items_key).count || 0
  end

  alias count total

  def pages_left
    pages_left? ? 1 : 0
  end

  def pages_left?
    data._raw[:next].present? # TODO use configuration
  end

  def parallel?
    false
  end
end
