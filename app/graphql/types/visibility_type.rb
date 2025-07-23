# frozen_string_literal: true

class Types::VisibilityType < Types::Base::Enum
  Visibility.list.each do |field_type|
    value field_type
  end
end