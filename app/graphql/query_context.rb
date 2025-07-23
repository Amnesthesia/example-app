class QueryContext < GraphQL::Query::Context
  # This lets the graphql pundit integration use
  # pundit_user instead of current_user which is default
  def pundit_user
    self[:pundit_user]
  end
end