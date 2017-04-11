module LHC
  class Railtie < Rails::Railtie
    initializer "lhc.configure_rails_initialization" do
      LHC::Caching.cache ||= Rails.cache
      LHC::Caching.logger ||= Rails.logger
    end
  end
end
