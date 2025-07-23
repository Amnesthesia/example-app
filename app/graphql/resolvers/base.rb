# frozen_string_literal: true

module Resolvers
  class Base < GraphQL::Schema::Resolver
    include GraphQL::Pro::PunditIntegration::ResolverIntegration

    # Disable pundit role by default
    pundit_role nil
  end
end
