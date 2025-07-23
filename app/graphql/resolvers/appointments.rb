class Resolvers::Appointments < Resolvers::Base
  type Types::AppointmentType.connection_type, null: false

  argument :time_range, Types::TimeRangeInput, required: false
  argument :state, Types::AppointmentStateType, required: false

  extras [:lookahead]

  def resolve(time_range: nil, state: nil, lookahead:)

    query = Appointment.all
    query = query.where(start_time: time_range[:start]..) if time_range && time_range[:start].present?
    query = query.where(end_time: ..time_range[:end])     if time_range && time_range[:end].present?
    query = query.where(state: state) if state.present?
    query
  end

  def scope
    Pundit.policy_scope!(context[:pundit_user], Appointment)
  end
end