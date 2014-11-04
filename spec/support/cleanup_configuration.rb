require 'lhc'
class LHC::Config

  def _cleanup
    @endpoints = {}
    @injections = {}
    @interceptors = nil
  end
end

RSpec.configure do |config|

  config.before(:each) do
    LHC::Config.instance._cleanup
  end

end
