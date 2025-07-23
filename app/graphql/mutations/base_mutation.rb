# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::Base::Argument
    field_class Types::Base::Field
    input_object_class Types::Base::InputObject
    object_class Types::Base::Object

    def unauthorized_by_pundit(...)
      return { errors: ["You are not authorized to perform this action."] }
    end
  end
end
