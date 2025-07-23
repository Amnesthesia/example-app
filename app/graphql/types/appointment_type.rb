# frozen_string_literal: true

class Types::AppointmentType < Types::Base::Object
  field :id, ID, null: false
  field :gid, ID, null: false, method: :to_gid_param
  field :title, String, null: false
  field :start_time, GraphQL::Types::ISO8601DateTime, null: false
  field :end_time, GraphQL::Types::ISO8601DateTime, null: false
  field :visibility, Types::VisibilityType, null: false
  field :appointment_guests, [Types::AppointmentGuestType], null: false, pundit_role: nil

  async_field :owner, Types::UserType
end