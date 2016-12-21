require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

require 'statesman'
require 'statesman-sequel'

describe "Sequel::Plugins::Statesman" do
  before do
    reset_db
  end

  it "defines Model.initial_state" do
    User.initial_state.must_equal "invited"
  end

  it "defines Model#state_machine" do
    user = User.new

    user.state_machine.must_be :kind_of?, UserStateMachine
    user.state_machine.object.must_equal user
  end

  it "defines Model#current_state" do
    user = User.create(name: "John")

    user.current_state.must_equal "invited"

    state_machine = user_machine(user)
    state_machine.transition_to! "registered"
    
    user.current_state.must_equal "registered"
  end

  it "defines Model#state! and Model#state?" do
    user = User.create(name: "John")

    user.invited?.must_equal true
    user.registered?.must_equal false

    user.registered!
    
    user.invited?.must_equal false
    user.registered?.must_equal true
  end

  it "defines Model#state_history" do
    user = User.create(name: "John")

    state_machine = user_machine(user)
    state_machine.transition_to!("registered")
    state_machine.transition_to!("blocked")

    user.state_history.must_equal user.state_machine.history
    user.state_history.must_equal UserTransition.order(:sort_key).all
  end

  it "overrides Model#refresh" do
    user = User.create(name: "John")
    same_user = User.first

    state_machine = user_machine(user)

    state_machine.transition_to!("registered")

    user.current_state.must_equal "registered"

    same_state_machine = user_machine(same_user)
    same_state_machine.transition_to!("blocked")

    user.current_state.must_equal "registered"

    user.refresh.current_state.must_equal "blocked"
  end
end
