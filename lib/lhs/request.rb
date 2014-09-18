require 'typhoeus'

class LHS::Request

  attr_accessor :data

  def initialize(options)
    Typhoeus::Hydra.hydra.queue request(options)
    Typhoeus::Hydra.hydra.run
    self
  end

  private

  def request(options)
    request = Typhoeus::Request.new(
      options[:url],
      method: options[:method],
      params: options[:params],
      headers: { 'Content-Type' => 'application/json' }
    )
    request.on_complete { |response| on_complete(response) }
    request
  end

  def on_complete(response)
    self.data = LHS::Data.new(response.body)
  end
end
