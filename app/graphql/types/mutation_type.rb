# frozen_string_literal: true

module Types
  class MutationType < Types::Base::Object
    field :update_appointment, mutation: Mutations::UpdateAppointment
  end
end
