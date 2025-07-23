# == Schema Information
#
# Table name: appointments
#
#  id              :integer          not null, primary key
#  title           :string
#  state           :string           default("draft")
#  start_time      :datetime
#  end_time        :datetime
#  organization_id :integer
#  owner_id        :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Appointment < ApplicationRecord
  belongs_to :organization
  belongs_to :owner, class_name: 'User', inverse_of: :created_appointments
  has_many :appointment_guests, inverse_of: :appointment

  has_enumeration_for :state, with: AppointmentStatus, create_helpers: true
end
