# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:data_hash) do
    { items: 98.times.map { { foo: 'bar' } }, limit: 10, next: { href: 'http://example.com/users?from_user_id=100&limit=100' } }
  end

  let(:data) do
    LHS::Data.new(data_hash, nil, Record)
  end

  let(:pagination) { LHS::Pagination::Link.new(data) }

  it 'responds to parallel?' do
    expect(pagination.parallel?).to be false
  end
end
