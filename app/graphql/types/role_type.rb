# frozen_string_literal: true

class Types::RoleType < Types::Base::Enum
  Role.list.each do |field_type|
    value field_type
  end
end