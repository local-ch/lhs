require 'rails_helper'

describe LHS::Record do
  context 'model_name' do
    before(:each) do
      class LocalEntry < LHS::Record
        endpoint '{+datastore}/local-entries'
      end
    end

    it 'provides a model name' do
      expect(LocalEntry.model_name.name).to eq 'LocalEntry'
    end
  end
end
