# frozen_string_literal: true

require 'rails_helper'

describe LHS::Record do
  context 'pagination' do
    let(:datastore) { 'http://local.ch/v2' }
    let(:record) { Feedback.where(entry_id: 1) }
    let(:total) { 200 }
    let(:total_pages) { total / limit }
    let(:current_page) { offset + 1 }
    let(:prev_page) { current_page - 1 }
    let(:next_page) { current_page + 1 }
    let(:offset) { 0 }
    let(:limit) { 10 }
    let(:body_json) do
      {
        items: [],
        total: total,
        offset: offset,
        limit: limit
      }.to_json
    end

    before do
      LHC.config.placeholder('datastore', datastore)
      class Feedback < LHS::Record
        endpoint '{+datastore}/feedbacks'
      end
      stub_request(:get, 'http://local.ch/v2/feedbacks?entry_id=1')
        .to_return(body: body_json)
    end

    it 'responds to limit_value' do
      expect(record.limit_value).to eq(limit)
    end

    it 'responds to total_pages' do
      expect(record.total_pages).to eq(total_pages)
    end

    it 'responds to current_page' do
      expect(record.current_page).to eq(current_page)
    end

    it 'responds to first_page' do
      expect(record.first_page).to eq(1)
    end

    it 'responds to last_page' do
      expect(record.last_page).to eq(total_pages)
    end

    it 'responds to prev_page' do
      expect(record.prev_page).to eq(prev_page)
    end

    it 'responds to next_page' do
      expect(record.next_page).to eq(next_page)
    end

    context 'when amount of total pages is not diviable by the limit' do
      let(:total) { 2738 }
      let(:limit) { 100 }

      it 'rounds up' do
        expect(record.total_pages).to eq(28)
      end
    end
  end
end
