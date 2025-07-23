module Types::Base
  class Edge < GraphQL::Schema::Object
    # add `node` and `cursor` fields, as well as `node_type(...)` override
    include GraphQL::Types::Relay::EdgeBehaviors
  end
end
