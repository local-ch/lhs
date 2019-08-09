module LHS

  module Interceptors

    module ExtendedRollbar
      
      class Handler

        def self.init
          proc do |options|
            # as handlers cant influence what actually is reported to rollbar
            # this just makes sure that Rollbar is already loaded when this class is loaded,
            # so that we can extend rollbar loging
          end
        end

        module ExtendedLogging

          def log(level, *args)
            args[2] = {} if args[2].nil?
            args[2][:lhs] = LHS::Interceptors::ExtendedRollbar::ThreadRegistry.log.map do |entry|
              {
                request: entry[:request].options,
                response: {
                  code: entry[:response].code,
                  body: entry[:response].body
                }
              }
            end.to_json
            super
          end
        end

        module ::Rollbar
          class Notifier
            prepend LHS::Interceptors::ExtendedRollbar::Handler::ExtendedLogging
          end
        end
      end
    end
  end
end
