require 'rails_helper'

describe LHS::Config do

  context 'environments' do
    it 'provides configuration for production' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      expect(LHS::Config[:datastore]).to eq 'datastore.lb-service'
    end

    it 'provides configuration for development' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      expect(LHS::Config[:datastore]).to eq 'datastore-stg.lb-service.sunrise.intra.local.ch'
    end

    it 'provides configuration for test' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      expect(LHS::Config[:datastore]).to eq 'datastore-stg.lb-service.interaction.intra.local.ch'
    end

    it 'provides configuration for all the others' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('whatever'))
      expect(LHS::Config[:datastore]).to eq 'datastore-stg.lb-service'
    end
  end 
end
