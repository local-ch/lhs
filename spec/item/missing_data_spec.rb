require 'rails_helper'

describe LHS::Item do

  before(:each) do
    class SomeService < LHS::Service
      endpoint ':datastore/v2/feedbacks'
    end
  end

  let(:json) do
    load_json(:feedbacks)
  end

  let(:data) do
    LHS::Data.new(json, nil, SomeService)
  end

  let(:item) do
    data[0]
  end

  it 'behaves like nil if some navigated nested data is not existing' do
    expect(item.foo.bar.nil?).to eq true
    expect(item.foo.bar.present?).to eq false
    expect(item.foo.bar == nil).to eq true
    expect(item.foo.bar).to eq nil
    expect(item.foo.bar.blank?).to eq true
    expect(item.foo.bar.duplicable?).to eq false
    expect(item.foo.bar.as_json?).to be_kind_of(NilClass)
    expect(item.foo.bar.to_param).to be_kind_of(NilClass)
    expect(item.foo.bar.try(:asd)).to be_kind_of(NilClass)
    expect(item.foo.bar.try!(:asd)).to be_kind_of(NilClass)
    expect(item.foo.bar.inspect).to eq 'nil'
    expect(item.foo.bar.to_a).to eq []
    expect(item.foo.bar.rationalize([])).to eq (0+0i)
    expect(item.foo.bar.to_c).to eq (0+0i)
    expect(item.foo.bar.to_f).to eq (0.0)
    expect(item.foo.bar.to_h).to eq ({})
    expect(item.foo.bar.to_i).to eq (0)
    expect(item.foo.bar.to_r).to eq (0)
    expect(item.foo.bar.to_s).to eq ('')
    expect(item.foo.bar | true).to be true
    expect(item.foo.bar & true).to be false
    expect(item.foo.bar || true).to be true
    expect(item.foo.bar && true).to be nil
  end
end
