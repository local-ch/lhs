# An endpoint is used as source to fetch objects
class LHS::Endpoint
  
  def self.for_url(url)
    template, service = LHS::Service::Endpoints.all.detect do |template, _service|
      LHC::Endpoint.match?(url, template)
    end
    service.endpoints.detect { |endpoint| endpoint.url == template } if service
  end
end

