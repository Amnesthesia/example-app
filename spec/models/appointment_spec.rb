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
require 'rails_helper'

RSpec.describe Appointment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
