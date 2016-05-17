require 'rails_helper'

describe LHS::Record do
  context 'misconfiguration of endpoints' do
    it 'fails trying to add clashing endpoints' do
      expect(
        lambda {
          class Record < LHS::Record
            endpoint ':datastore/v2/feedbacks'
            endpoint ':datastore/v2/reviews'
          end
        }
      ).to raise_error
      expect(
        lambda {
          class Record < LHS::Record
            endpoint ':datastore/v2/:campaign_id/feedbacks'
            endpoint ':datastore/v2/:campaign_id/reviews'
          end
        }
      ).to raise_error
    end
  end
end
