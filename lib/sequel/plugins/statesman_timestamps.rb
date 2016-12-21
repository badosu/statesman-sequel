module Sequel
  module Plugins
    module StatesmanTimestamps
      OPTS = {}.freeze

      DEFAULTS = {
        create: :created_at
      }

      def self.configure!(opts=OPTS)
        DEFAULTS.merge!(opts)
      end

      def self.configure(model, opts=OPTS)
        opts = DEFAULTS.merge(opts)

        model.instance_eval do
          @statesman_timestamp_options = opts
        end
      end

      module DatasetMethods
        def state_changed_after(date)
          where(%["#{model.most_recent_transition_association_name
                  }"."#{@statesman_timestamp_options[:create]}" > ?], date)
        end

        def state_changed_before(date)
          where(%["#{model.most_recent_transition_association_name
                  }"."#{@statesman_timestamp_options[:create]}" < ?], date)
        end
      end
    end
  end
end
