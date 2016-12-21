# Sequel Statesman

Ships Sequel adapter and a Sequel plugin for Statesman

## Regular Configuration

Similar to the ActiveRecord configuration but with the changes required for
Sequel:

```ruby
require 'sequel-statesman'

Statesman.configure do
  storage_adapter(Statesman::Adapters::Sequel)
end

class UserStateMachine
  include Statesman::Machine

  state :invited, initial: true
  state :registered

  transition from: :invited, to: :registered
end

class UserTransition < Sequel::Model
  include Statesman::Adapters::SequelTransition

  many_to_one :user
end

class User < Sequel::Model
  include Statesman::Adapters::SequelQueries

  one_to_many :user_transitions

  def state_machine
    @state_machine ||= UserStateMachine.new(self, transition_class: UserTransition)
  end

  def self.transition_class
    UserTransition
  end
  private_class_method :transition_class

  def self.initial_state
    :invited
  end
  private_class_method :initial_state
end
```

Creating user\_transitions table:

```ruby
Sequel.migration do
  up do
    create_table(:user_transitions) do
      primary_key :id

      String :to_state, null: false, size: 255
      String :metadata, default: "{}"
      Integer :sort_key, null: false
      TrueClass :most_recent, null: false
      # Remove last argument above if your database does not support
      # partial indexes

      foreign_key :user_id, :users, null: false

      index %i[user_id sort_key], unique: true
      index %i[user_id most_recent], unique: true, where: 'most_recent'
      # Remove last argument above if your database does not support
      # partial indexes
    end
  end

  down do
    drop_table(:user_transitions)
  end
end
```

## Sequel Plugin

You will perform the same configuration above, except for the model:

```ruby
class User < Sequel::Model
  plugin :statesman
end
```

The following methods will be delegated to the state machine:

- `#current_state`
- `#state_machine_history`
- `#last_transition`

The following methods will be defined on your model:

- `.initial_state`
- `#state_machine`
- `#state_name?` method for each state on your state machine
- `#state_name!(metadata={})` method for each state on your state machine.
- `#state_machine_history`
- `#transition_metadata`
- `#merge_transition_metadata(metadata)`
- `#refresh` overriden to also reload your states

### Configuration

You may perform individual model configuration when the plugin is included:

```ruby
plugin :statesman, transition_class: UserEvent,
                   state_machine_class: UserMachine
```

Or globally:

```ruby
require 'sequel/plugins/statesman'
Sequel::Plugins::Statesman.configure!({
  transition_class: ->(model) { "#{model.name}Event".constantize }
  state_machine_class: ->(model) { "#{model.name}Machine".constantize }
})
```

The defaults are:

```ruby
define_state_methods: true, # If defines #state! and #state? methods
destroy_transitions: true, # If the transitions are automatically destroyed when the parent instance is destroyed
include_queries: true, # If SequelQueries is automatically included
transition_class: ->(model) { "#{model.name}Transition".constantize }, # The transition class for the model
state_machine_class: ->(model) { "#{model.name}StateMachine".constantize } # The state machine for the model
```

### Sequel Timestamps

If your transition classes use the timestamps plugin you may include
the `statesman_timestamps` plugin to add the following DataSetMethods:

- `.state_changed_after(date)` to filter records by date of last transition
- `.state_changed_before(date)` to filter records by date of last transition

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/badosu/statesman-sequel

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
