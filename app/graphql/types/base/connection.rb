module Types::Base
  class Connection < GraphQL::Schema::Object
    include GraphQL::Types::Relay::ConnectionBehaviors

    field :total_count, Integer, null: false, description: 'Returns total count of items in list'

    def total_count
      # If the query is doing a group/having,
      # then #size and #count will be a hash
      # of counts for each group, so sum the values
      return object.items.size.values.sum if object.items.size.is_a?(Hash)
      object.items.size
    end
  end
end
