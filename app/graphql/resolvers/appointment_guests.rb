class Resolvers::AppointmentGuests < Resolvers::Base
  type Types::AppointmentGuestType.connection_type, null: false

  extras [:lookahead]

  def resolve(lookahead:)
    fields = lookahead.selection(:edges).selection(:node)

    query = scope
    query = query.includes(:appointment) if fields.selects?(:appointment)
    query
  end

  def scope
    Pundit.policy_scope!(context[:pundit_user], AppointmentGuest)
  end
end