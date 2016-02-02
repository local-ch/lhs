# An endpoint is used as source to fetch objects
class LHS::Endpoint

  def self.for_url(url)
    template, record = LHS::Record::Endpoints.all.detect do |template, _record_class|
      LHC::Endpoint.match?(url, template)
    end
    record.endpoints.detect { |endpoint| endpoint.url == template } if record
  end
end
