require 'pry'
require 'minitest/autorun'
require 'minitest/hooks/default'

require 'statesman-sequel'

Statesman.configure do
  storage_adapter(Statesman::Adapters::Sequel)
end

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id

  String :name, null: false
end

DB.create_table :user_transitions do
  primary_key :id

  String :to_state, null: false, size: 255
  String :metadata, default: "{}"
  Integer :sort_key, null: false
  TrueClass :most_recent, null: false

  foreign_key :user_id, :users, null: false

  index %i[user_id sort_key], unique: true
  index %i[user_id most_recent], unique: true, where: 'most_recent'
end

def reset_db()
  DB[:user_transitions].truncate
  DB[:users].truncate
end

def reset_const(conts=%w[User UserTransition UserStateMachine])
  Array(consts).each do |const|
    Object.send(:remove_const, const) if Object.const_defined? const
  end
end

def user_machine(instance)
  UserStateMachine.new(instance, transition_class: UserTransition)
end

class UserStateMachine
  include Statesman::Machine

  state :invited, initial: true
  state :registered
  state :blocked

  transition from: :invited, to: :registered
  transition from: :registered, to: :blocked
end

class UserTransition < Sequel::Model
  include Statesman::Adapters::SequelTransition

  many_to_one :user
end

class User < Sequel::Model
  plugin :statesman
end
