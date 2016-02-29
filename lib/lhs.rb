require 'lhc'

module LHS
end

Gem.find_files('lhs/**/*.rb').each { |path| require path }

# Preload all the LHS::Records that are defined in app/models
class Engine < Rails::Engine
  initializer 'Load all LHS::Records' do |app|
    Dir.glob(app.root.join('app/services/**/*.rb')).each do |file|
      require file if File.read(file).scan('LHS::Record')
    end
  end
end
