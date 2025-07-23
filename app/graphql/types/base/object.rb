module Types::Base
  class Object < GraphQL::Schema::Object
    include CustomFields
    field_class(::Types::Base::Field)
    edge_type_class(::Types::Base::Edge)
    connection_type_class(Types::Base::Connection)
  end
end
