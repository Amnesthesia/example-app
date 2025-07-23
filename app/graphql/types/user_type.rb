# frozen_string_literal: true

class Types::UserType < Types::Base::Object
  field :id, ID, null: false
  field :gid, ID, null: false, method: :to_gid_param
  field :name, String, null: false
  field :role, Types::RoleType, null: false
  async_field :organization, Types::OrganizationType
end