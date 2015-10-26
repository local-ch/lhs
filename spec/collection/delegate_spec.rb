require 'rails_helper'

describe LHS::Collection do

  let(:data) {
    ['ROLE_USER', 'ROLE_LOCALCH_ACCOUNT']
  }

  let(:collection){
    described_class.new(LHS::Data.new(data))
  }

  context 'delegates methods to raw' do

    %w(present? blank? empty?).each do |method|
      it "delegates #{method} to raw" do
        expect(collection.send(method.to_sym)).not_to be_nil
      end
    end
  end
end
