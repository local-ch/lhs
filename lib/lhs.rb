require 'lhc'

module LHS
  class RequireLhsRecords
    def initialize(app)
      @app = app
    end

    def call(env)
      self.class.require_records
      @app.call(env)
    end

    def self.require_records
      Dir.glob(Rails.root.join('app/models/**/*.rb')).each do |file|
        require_dependency file if File.read(file).match('LHS::Record')
      end
    end
  end
end

Gem.find_files('lhs/**/*.rb').sort.each { |path| require path }

# Preload all the LHS::Records that are defined in app/models
class Engine < Rails::Engine
  initializer 'Load all LHS::Records from app/models/**' do |app|
    LHS::RequireLhsRecords.require_records
    next if app.config.cache_classes

    app.config.middleware.use LHS::RequireLhsRecords
  end
end
