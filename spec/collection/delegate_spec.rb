require 'rails_helper'

describe LHS::Collection do
  let(:data) do
    ['ROLE_USER', 'ROLE_LOCALCH_ACCOUNT']
  end

  let(:collection) do
    LHS::Collection.new(LHS::Data.new(data))
  end

  context 'delegates methods to raw' do
    %w(length size last sample present? blank? empty? compact).each do |method|
      it "delegates #{method} to raw" do
        expect(collection.send(method.to_sym)).not_to be_nil
      end
    end
  end
end
