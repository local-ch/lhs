require 'rails_helper'

describe LHS::Item do

  before do
    class Presence < LHS::Record
      endpoint 'http://opm/presence'
    end

    I18n.reload!
    I18n.backend.store_translations(:en, YAML.safe_load(%q{
      lhs:
        warnings:
          records:
            presence:
              will_be_resized: 'The photos will be resized'
    }))
  end

  it 'provides warnings together with validation errors' do
    stub_request(:post, "http://opm/presence?synchronize=false")
      .to_return(
        body: {
          field_warnings: [{
            code: 'WILL_BE_RESIZED',
            path: ['place', 'photos', 0],
            message: 'The image will be resized.'
          }],
          place: {
            href: 'http://storage/places/1',
            photos: [{
              href: 'http://bin.staticlocal.ch/123',
              width: 10,
              height: 10
            }]
          }
        }.to_json
      )
    presence = Presence.options(params: { synchronize: false }).create(
      place: { href: 'http://storage/places/1' }
    )
    expect(presence.warnings.any?).to eq true
    expect(presence.place.warnings.any?).to eq true
    expect(presence.place.photos.warnings.any?).to eq true
    expect(presence.place.photos[0].warnings.any?).to eq true
    expect(presence.place.photos[0].warnings.messages.first).to eq(
      'The photos will be resized'
    )
  end
end
