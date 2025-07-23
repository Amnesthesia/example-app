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
require 'rails_helper'

RSpec.describe AppointmentGuest, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
