module Mutations
  class UpdateAppointment < BaseMutation
    field :appointment, Types::AppointmentType, null: true
    argument :id, ID, required: true,
               as: :appointment,
               loads: Types::AppointmentType,
               pundit_role: :update,
               prepare: ->(id, _ctx) { Appointment.global_id_for(id) }
    argument :time_range, Types::TimeRangeInput, required: false
    argument :state, Types::AppointmentStateType, required: false

    def resolve(time_range: nil, state: nil, appointment: nil)
      binding.pry
      appointment.assign_attributes(
        start_time: time_range&.start_time || appointment.start_time,
        end_time: time_range&.end_time || appointment.end_time,
        state: state || appointment.state
      )

      return { appointment: appointment } if appointment.save
      { appointment: nil }
    end
  end
end