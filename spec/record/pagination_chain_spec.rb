require 'rails_helper'

describe LHS::Record do
  context 'pagination chain' do
    context 'default pagination (offset)' do
      before(:each) do
        class Record < LHS::Record
          endpoint 'http://local.ch/records'
          endpoint 'http://local.ch/records/:id'
        end
      end

      it 'allows to chain pagination methods' do
        stub_request(:get, "http://local.ch/records?color=blue&offset=200&limit=100").to_return(body: [].to_json)
        Record.where(color: 'blue').page(3).first
        stub_request(:get, "http://local.ch/records?color=blue&offset=20&limit=10").to_return(body: [].to_json)
        Record.where(color: 'blue').page(3).per(10).first
        Record.where(color: 'blue').per(10).page(3).first
        Record.where(color: 'blue').per(20).page(5).per(10).page(3).first
      end

      it 'allows to start chains with pagination methods' do
        stub_request(:get, "http://local.ch/records?color=blue&offset=200&limit=100").to_return(body: [].to_json)
        Record.page(3).where(color: 'blue').first
        stub_request(:get, "http://local.ch/records?color=blue&offset=20&limit=10").to_return(body: [].to_json)
        Record.page(3).per(10).where(color: 'blue').first
        Record.per(10).page(3).where(color: 'blue').first
        Record.per(20).page(5).where(color: 'blue').per(10).page(3).first
      end

      it 'defaults page to 1' do
        stub_request(:get, "http://local.ch/records?limit=10&offset=0").to_return(body: [].to_json)
        Record.per(10).first
        Record.per(10).page("").first
      end
    end

    context 'start pagination' do
      before(:each) do
        class Record < LHS::Record
          configuration pagination_strategy: 'start', pagination_key: 'start'
          endpoint 'http://local.ch/records'
          endpoint 'http://local.ch/records/:id'
        end
      end

      it 'allows to chain pagination methods' do
        stub_request(:get, "http://local.ch/records?color=blue&start=201&limit=100").to_return(body: [].to_json)
        Record.where(color: 'blue').page(3).first
        stub_request(:get, "http://local.ch/records?color=blue&start=21&limit=10").to_return(body: [].to_json)
        Record.where(color: 'blue').page(3).per(10).first
        Record.where(color: 'blue').per(10).page(3).first
        Record.where(color: 'blue').per(20).page(5).per(10).page(3).first
      end
    end

    context 'page pagination' do
      before(:each) do
        class Record < LHS::Record
          configuration pagination_strategy: 'page', pagination_key: 'page'
          endpoint 'http://local.ch/records'
          endpoint 'http://local.ch/records/:id'
        end
      end

      it 'allows to chain pagination methods' do
        stub_request(:get, "http://local.ch/records?color=blue&page=3&limit=100").to_return(body: [].to_json)
        Record.where(color: 'blue').page(3).first
        stub_request(:get, "http://local.ch/records?color=blue&page=3&limit=10").to_return(body: [].to_json)
        Record.where(color: 'blue').page(3).per(10).first
        Record.where(color: 'blue').per(10).page(3).first
        Record.where(color: 'blue').per(20).page(5).per(10).page(3).first
      end
    end
  end
end
