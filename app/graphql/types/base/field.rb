module Types::Base
  class Field < GraphQL::Schema::Field
    include GraphQL::Pro::PunditIntegration::FieldIntegration
    argument_class Types::Base::Argument
    pundit_role nil
  end
end