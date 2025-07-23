class Types::AppointmentStateType < Types::Base::Enum
  ::AppointmentStatus.list.each do |status|
    value status
  end
end