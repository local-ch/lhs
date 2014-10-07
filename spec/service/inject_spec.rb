require 'rails_helper'

describe LHS::Service do

  context 'inject' do

    it 'injects parameters into and endpoint to get a proper url' do
      endpoint = LHC::Endpoint.new(':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks')
      expect(
        LHS::Service.instance.inject(
          endpoint,
          entry_id: '123', campaign_id: '456'
        )
      ).to eq 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/entries/123/content-ads/456/feedbacks'
    end

    it 'removes parameters when they are use to inject them to generate url' do
      params = { entry_id: '123', campaign_id: '456', has_reviews: true }
      endpoint = LHC::Endpoint.new(':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks')
      LHS::Service.instance.remove_injected_params!(params, endpoint)
      expect(params).to eq(has_reviews: true)
    end

    context 'exceptions' do

      it 'fails injecting parameters into endpoint when some injections left empty' do
        endpoint = LHC::Endpoint.new(':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks')
        expect(
          ->{
            LHS::Service.instance.inject(
              endpoint,
              entry_id: '123'
            )
          }
        ).to raise_error('Incomplete injection. Unable to inject campaign_id.')
      end
    end
  end
end
