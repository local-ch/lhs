# frozen_string_literal: true

require 'active_support'

# Preload all the LHS::Records that are defined in app/models/*
# in order to collect record endpoints and to be able to identify records from hrefs
# and not only from model constant names (which is different to ActiveRecord)
module AutoloadRecords
  extend ActiveSupport::Concern

  included do
    class Engine < Rails::Engine
      initializer 'Load all LHS::Records from app/models/**' do |app|
        Middleware.require_records
        next if app.config.cache_classes

        app.config.middleware.use Middleware
      end

      class Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          self.class.require_records
          @app.call(env)
        end

        def self.model_files
          Dir.glob(Rails.root.join('app', 'models', '**', '*.rb'))
        end

        def self.require_direct_inheritance
          model_files.map do |file|
            next unless File.read(file).match('LHS::Record')
            require_dependency file
            file.split('models/').last.gsub('.rb', '').classify
          end.compact
        end

        def self.require_inheriting_records(parents)
          model_files.each do |file|
            next if parents.none? { |parent| File.read(file).match(parent) }
            require_dependency file
          end
        end

        def self.require_records
          require_inheriting_records(require_direct_inheritance)
        end
      end
    end
  end
end
