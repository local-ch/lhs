# frozen_string_literal: true

# An endpoint is used as source to fetch objects
class LHS::Endpoint

  def self.for_url(url)
    template, record = LHS::Record::Endpoints.all.detect do |template, _record|
      LHC::Endpoint.match?(url, template)
    end
    record&.endpoints&.detect { |endpoint| endpoint.url == template }
  end
end
