require 'lhc'

module LHS
end

Gem.find_files('lhs/**/*.rb').each { |path| require path }

# Preload all the services that are defined in app/services
class Engine < Rails::Engine
  initializer 'Load all services' do |app|
    Dir.glob(app.root.join('app/services/**.rb')).each {|file| require file }
  end
end
