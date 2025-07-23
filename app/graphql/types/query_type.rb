# frozen_string_literal: true

module Types
  class QueryType < Types::Base::Object
    field :appointments, resolver: Resolvers::Appointments
    field :appointment_guests, resolver: Resolvers::AppointmentGuests
  end
end
