require 'rails_helper'

describe LHS::Service do

  context 'inject' do

    it 'injects parameters into and endpoint to get a proper url' do
      expect(
        LHS::Service.instance.inject(
          ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks',
          entry_id: '123', campaign_id: '456'
        )
      ).to eq 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/entries/123/content-ads/456/feedbacks'
    end

    it 'removes parameters when they are use to inject them to generate url' do
      expect(
        LHS::Service.instance.remove_injected_params(
          { entry_id: '123', campaign_id: '456', has_reviews: true },
          ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks'
        )
      ).to eq(has_reviews: true)
    end

    it 'lets the original hash untouched when removing injected params' do
      hash = { entry_id: '123', campaign_id: '456', has_reviews: true }
      LHS::Service.instance.remove_injected_params(hash,':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks')
      expect(hash).to eq({ entry_id: '123', campaign_id: '456', has_reviews: true })
    end

    context 'exceptions' do

      it 'fails injecting parameters into endpoint when some injections left empty' do
        expect(
          ->{
            LHS::Service.instance.inject(
              ':datastore/v2/entries/:entry_id/content-ads/:campaign_id/feedbacks',
              entry_id: '123'
            )
          }
        ).to raise_error('Incomplete injection. Unable to inject campaign_id.')
      end
    end
  end
end
