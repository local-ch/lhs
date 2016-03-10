require 'lhc'

module LHS
end

Gem.find_files('lhs/**/*.rb').each { |path| require path }

# Preload all the LHS::Records that are defined in app/models
class Engine < Rails::Engine
  initializer 'Load all LHS::Records from app/models/**' do |app|
    Dir.glob(app.root.join('app/models/**/*.rb')).each do |file|
      require file if File.read(file).match('LHS::Record')
    end
  end
end
