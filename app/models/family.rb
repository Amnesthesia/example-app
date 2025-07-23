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
class Family < ApplicationRecord
  validates_presence_of :name, message: "Family name can't be blank"

  belongs_to :organization

  has_many :family_members, inverse_of: :family
  has_many :users, through: :family_members

  has_many :visible_family_members, -> { visible },
           class_name: 'FamilyMember',
           foreign_key: :family_id,
           inverse_of: :family
  has_many :visible_household,
           through: :visible_family_members,
           source: :user
end
