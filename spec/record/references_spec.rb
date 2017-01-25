describe LHS::Record do

  context 'references' do
    before(:each) do
      class Customer < LHS::Record
        endpoint ':datastore/customers/:id'
      end
    end

    let!(:customer_request) do
      stub_request(:get, "#{datastore}/customers/1")
        .to_return(body: {
          'electronic_addresses' => {
            'href' => "#{datastore}/electronic_addresses"
          },
          'contact_addresses' => {
            'href' => "#{datastore}/contact_addresses"
          }
        }.to_json)
    end

    let!(:electronic_addresses_request) do
      stub_request(:get, "http://local.ch/v2/electronic_addresses")
        .with(headers: { 'Authentication' => "Bearer 123" })
        .to_return(body: [].to_json)
    end

    let!(:contact_addresses_request) do
      stub_request(:get, "http://local.ch/v2/contact_addresses")
        .with(headers: { 'Authentication' => "Bearer 123" })
        .to_return(body: [].to_json)
    end

    let(:referencing_options) do
      { headers: { 'Authentication': 'Bearer 123' } }
    end

    it 'uses the "references" hash for all symbols of the "including" array' do
      customer = Customer
        .includes(:electronic_addresses, :contact_addresses)
        .references(
          electronic_addresses: referencing_options,
          contact_addresses: referencing_options
        )
        .find(1)
      expect(customer.electronic_addresses).to eq []
      expect(customer.contact_addresses).to eq []
      assert_requested(electronic_addresses_request)
      assert_requested(contact_addresses_request)
    end
  end
end
