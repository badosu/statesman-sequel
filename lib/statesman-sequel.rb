require 'sequel'
require 'statesman'
require 'statesman-sequel/version'

module Statesman
  module Adapters
    autoload :Sequel,           'statesman/adapters/sequel'
    autoload :SequelQueries,    'statesman/adapters/sequel_queries'
    autoload :SequelTransition, 'statesman/adapters/sequel_transition'
  end
end

Sequel.extension :inflector
