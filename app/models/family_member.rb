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
class FamilyMember < ApplicationRecord
  belongs_to :user
  belongs_to :family

  # Family Members that are visible to other family members
  # can let other family members see and manage their appointments.
  # This visibility determines whether it shows up in a FamilyMember
  # select in the frontend.
  scope :visible, -> { where(visibility: Visibility::STAFF_AND_CLIENTS) }

  has_enumeration_for :visibility, create_helpers: true
end
