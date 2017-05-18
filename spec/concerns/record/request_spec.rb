require 'rails_helper'

describe LHS::Record::Request do
  subject { Class.new { include(LHS::Record::Request) } }

  describe 'prepare_options_for!' do
    it 'calls correct prepare method for nil' do
      expect(subject).to receive(:prepare_option_for_testing!)
        .with(nil, 'arg').and_return('ignore')
      expect(subject.send(:prepare_options_for!, :testing, nil, 'arg')).to eq({})
    end

    it 'calls correct prepare method for a Hash' do
      expect(subject).to receive(:prepare_option_for_testing!)
        .with({ abc: 'def' }, 'arg').and_return('ignore')
      expect(subject.send(:prepare_options_for!, :testing, { abc: 'def' }, 'arg')).to eq(abc: 'def')
    end

    it 'calls correct prepare method for a Hash' do
      expect(subject).to receive(:prepare_option_for_testing!)
        .with({ abc: 'def' }, 'arg').and_return('ignore')
      expect(subject).to receive(:prepare_option_for_testing!)
        .with({ hij: 'kel' }, 'arg').and_return('ignore')
      expect(subject.send(:prepare_options_for!, :testing, [{ abc: 'def' }, { hij: 'kel' }], 'arg'))
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
end
