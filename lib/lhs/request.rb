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
      method: options[:method] || :get,
      params: options[:params],
      body: options[:body],
      headers: { 'Content-Type' => 'application/json' },
      followlocation: true
    )
    request.on_complete { |response| on_complete(response) }
    request
  end

  def on_complete(response)
    if response.code.to_s[/^(2\d\d+)/]
      on_success(response)
    else
      on_error(response)
    end
  end

  def on_success(response)
    self.data = response.body
  end

  def on_error(response)
    error = LHS::Error.find(response.code)
    fail(error, "#{response.code} #{response.body}")
  end
end
