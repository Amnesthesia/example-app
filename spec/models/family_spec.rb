# == Schema Information
#
# Table name: families
#
#  id              :integer          not null, primary key
#  name            :string
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe Family, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
