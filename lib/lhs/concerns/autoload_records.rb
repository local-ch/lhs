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

        def self.all_model_rb_files
          Rails.root.join('app', 'models', '**', '*.rb')
        end

        def self.require_records
          klasses = []

          Dir.glob(all_model_rb_files).each do |file|
            next unless File.read(file).match('LHS::Record')
            require_dependency file
            klasses << file.split('models/').last.gsub('.rb', '').classify
          end

          Dir.glob(all_model_rb_files).each do |file|
            next if klasses.none? { |klass| File.read(file).match(klass) }
            require_dependency file
          end
        end
      end
    end
  end
end
