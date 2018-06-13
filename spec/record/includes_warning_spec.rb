require 'rails_helper'

describe LHS::Record do
  context 'includes warning' do
    before do
      class Customer < LHS::Record
        endpoint 'http://datastore/customers/{id}'
      end
    end

    let!(:customer_request) do
      stub_request(:get, 'http://datastore/customers/1')
        .to_return(
          body: {
            contracts: { href: 'http://datastore/customers/1/contracts' }
          }.to_json
        )
    end

    let!(:contracts_request) do
      stub_request(:get, "http://datastore/customers/1/contracts")
        .to_return(
          body: {
            items: 10.times.map do
              {
                products: { href: 'http://datastore/products' }
              }
            end,
            limit: 10,
            offset: 0,
            total: 33
          }.to_json
        )
    end

    it 'warns if linked data was simply included but is paginated' do
      expect(lambda {
        Customer.includes(:contracts).find(1)
      }).to output(
        %r{\[WARNING\] You included `http://datastore/customers/1/contracts`, but this endpoint is paginated. You might want to use `includes_all` instead of `includes` \(https://github.com/local-ch/lhs#includes_all-for-paginated-endpoints\)\.}
      ).to_stderr
    end
  end
end
