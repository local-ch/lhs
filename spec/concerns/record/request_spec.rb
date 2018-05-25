require 'rails_helper'

describe LHS::Record::Request do
  subject do
    Class.new do
      include LHS::Record::Configuration
      include LHS::Record::Request
    end
  end

  describe 'prepare_options_for_include_all_request' do
    it 'calls correct prepare method for nil' do
      expect(subject).to receive(:prepare_option_for_include_all_request!)
        .with(nil).and_return('ignore')
      expect(subject.send(:prepare_options_for_include_all_request!, nil)).to be_nil
    end

    it 'calls correct prepare method for a Hash' do
      expect(subject).to receive(:prepare_option_for_include_all_request!)
        .with(abc: 'def').and_return('ignore')
      expect(subject.send(:prepare_options_for_include_all_request!, abc: 'def')).to eq(abc: 'def')
    end

    it 'calls correct prepare method for a Hash' do
      expect(subject).to receive(:prepare_option_for_include_all_request!)
        .with(abc: 'def').and_return('ignore')
      expect(subject).to receive(:prepare_option_for_include_all_request!)
        .with(hij: 'kel').and_return('ignore')
      expect(subject.send(:prepare_options_for_include_all_request!, [{ abc: 'def' }, { hij: 'kel' }]))
        .to eq([{ abc: 'def' }, { hij: 'kel' }])
    end
  end

  describe 'prepare_option_for_incldue_all_request' do
    it 'removes all limit and offset parameters' do
      option = { url: 'http://localhost:3000/test/resource?abc=def&limit=1&offset=3&test=2' }
      expect(subject.send(:prepare_option_for_include_all_request!, option))
        .to eq(option)
      expect(option).to eq(url: 'http://localhost:3000/test/resource',
                           params: { limit: 100, abc: 'def', test: '2' })
    end

    it 'do nothing without url' do
      option = { param: { abc: 'def' } }
      expect(subject.send(:prepare_option_for_include_all_request!, option))
        .to eq(option)
      expect(option).to eq(param: { abc: 'def' })
    end

    it 'raises an exception when url invalid' do
      option = { param: { abc: 'def' }, url: 'http://ab de.com/resource' }
      expect { subject.send(:prepare_option_for_include_all_request!, option) }
        .to raise_exception(URI::InvalidURIError)
      expect(option).to eq(param: { abc: 'def' }, url: 'http://ab de.com/resource')
    end

    it 'keeps current params over url params' do
      option = { url: 'http://localhost:3000/test/resource?abc=def&limit=1&offset=3&test=2',
                 params: { abc: '123' } }
      expect(subject.send(:prepare_option_for_include_all_request!, option))
        .to eq(option)
      expect(option).to eq(url: 'http://localhost:3000/test/resource',
                           params: { limit: 100, abc: '123', test: '2' })
    end

    it 'removes including and referening options' do
      option = { url: 'http://localhost:3000/test/resource',
                 including: 'all',
                 referencing: 'nothing' }
      expect(subject.send(:prepare_option_for_include_all_request!, option))
        .to eq(option)
      expect(option).to eq(url: 'http://localhost:3000/test/resource',
                           params: { limit: 100 })
    end
  end

  describe 'load_and_merge_set_of_paginated_collections!' do
    let(:options) do
      [
        {
          url: 'http://localhost:3000/test/resource?abc=def&limit=1&offset=3&test=1',
          all: true,
          auth: { bearer: 'xxx' },
          params: { limit: 100 }
        }
      ]
    end
    let(:data) do
      [
        LHS::Record.new,
        nil,
        LHS::Record.new,
      ]
    end

    it 'returns even if data has nil elements' do
      expect(subject.send(:load_and_merge_set_of_paginated_collections!, data, options)).to eq('asdf')
    end
  end
end
