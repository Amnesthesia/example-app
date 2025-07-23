# frozen_string_literal: true

class Types::AppointmentGuestType < Types::Base::Object
  include GraphQL::Pro::PunditIntegration::ObjectIntegration
  pundit_role :show
  field :id, ID, null: false
  field :gid, ID, null: false, method: :to_gid_param
  
  async_field :appointment, Types::AppointmentType
  async_field :user, Types::UserType
end