require 'lhc'

module LHS
end

Gem.find_files('lhs/**/*.rb').each { |path| require path }
