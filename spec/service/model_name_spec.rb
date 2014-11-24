require 'rails_helper'

describe LHS::Service do

  context 'model_name' do

    before(:each) do
      class LocalEntry < LHS::Service
        endpoint ':datastore/local-entries'
      end
    end

    it 'provides a model name' do
      expect(LocalEntry.model_name.name).to eq 'LocalEntry'
    end
  end
end
