# == Schema Information
#
# Table name: family_members
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  family_id  :integer          not null
#  visibility :string           default("staff")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe FamilyMember, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
