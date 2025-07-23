# == Schema Information
#
# Table name: appointment_guests
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  appointment_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class AppointmentGuest < ApplicationRecord
  belongs_to :user
  belongs_to :appointment
end
