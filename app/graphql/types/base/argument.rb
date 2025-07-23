module Types::Base
  class Argument < GraphQL::Schema::Argument
    include GraphQL::Pro::PunditIntegration::ArgumentIntegration
    pundit_role nil
  end
end
