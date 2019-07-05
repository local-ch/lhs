# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:next_href) { 'http://example.com/users?from_user_id=100&limit=100' }
  let(:data_hash) do
    { items: 98.times.map { { foo: 'bar' } }, limit: 10, next: { href: next_href } }
  end

  let(:data) do
    LHS::Data.new(data_hash, nil, Record)
  end

  let(:pagination) { LHS::Pagination::Link.new(data) }

  it 'responds to next_link' do
    expect(pagination.next_link).to eq(next_href)
  end
end
