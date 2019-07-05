# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  let(:offset) { 0 }
  let(:data_hash) { { items: 98.times.map { { foo: 'bar' } }, total: 98, offset: offset, limit: 10 } }

  let(:data) do
    LHS::Data.new(data_hash, nil, Record)
  end

  let(:pagination) { LHS::Pagination::Offset.new(data) }

  it 'responds to pages_left' do
    expect(pagination.pages_left).to eq(9)
  end

  context 'when there is no offset' do
    let(:offset) { nil }

    it 'responds to pages_left' do
      expect(pagination.pages_left).to eq(9)
    end
  end
end
