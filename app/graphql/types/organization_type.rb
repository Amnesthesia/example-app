# frozen_string_literal: true

class Types::OrganizationType < Types::Base::Object
  field :id, ID, null: false
  field :gid, ID, null: false, method: :to_gid_param
  field :name, String, null: false
end