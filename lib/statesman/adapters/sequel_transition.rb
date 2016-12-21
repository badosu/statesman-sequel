module Statesman
  module Adapters
    module SequelTransition
      def self.included(base)
        base.instance_eval do
          plugin :serialization

          serialize_attributes :json, :metadata
        end
      end
    end
  end
end
