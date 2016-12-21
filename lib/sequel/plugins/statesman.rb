require 'statesman-sequel'

module Sequel
  module Plugins
    module Statesman
      OPTS = {}.freeze

      DEFAULTS = {
        define_state_methods: true,
        destroy_transitions: true,
        include_queries: true,
        transition_class: ->(model) { "#{model.name}Transition".constantize },
        state_machine_class: ->(model) { "#{model.name}StateMachine".constantize }
      }

      def self.configure!(opts=OPTS)
        DEFAULTS.merge!(opts)
      end

      def self.configure(model, opts=OPTS)
        opts = DEFAULTS.merge(opts)

        model.instance_eval do
          if opts[:state_machine_class].respond_to? :to_proc
            @state_machine_class = opts[:state_machine_class].call(self)
          else
            @state_machine_class = opts[:state_machine_class]
          end

          if opts[:transition_class].respond_to? :to_proc
            @transition_class = opts[:transition_class].call(self)
          else
            @transition_class = opts[:transition_class]
          end

          if opts[:define_state_methods]
            @state_machine_class.states.each do |state|
              define_method(:"#{state}!") do |metadata = {}|
                state_machine.transition_to!(state, metadata)
              end

              define_method(:"#{state}?") do
                current_state == state
              end
            end
          end

          if opts[:include_queries]
            include ::Statesman::Adapters::SequelQueries
          end

          if opts[:destroy_transitions]
            plugin :association_dependencies
            add_association_dependencies transition_name => :destroy
          end
        end
      end

      module ClassMethods
        attr_reader :transition_class
        attr_reader :state_machine_class

        def initial_state
          state_machine_class.initial_state
        end
      end

      module InstanceMethods
        def transition_metadata
          transition = last_transition(force_reload: true)

          transition && transition.metadata
        end

        def merge_transition_metadata!(value)
          metadata = transition_metadata

          last_transition.update(metadata: metadata.merge(value))
        end

        def refresh
          state_machine.last_transition(force_reload: true)

          super
        end

        def current_state(*args)
          state_machine.current_state(*args)
        end

        def last_transition(*args)
          state_machine.last_transition(*args)
        end

        def state_machine_history(*args)
          state_machine.history(*args)
        end

        def state_machine
          @state_machine ||= model.state_machine_class.new(
            self,
            transition_class: model.transition_class
          )
        end
      end
    end
  end
end
