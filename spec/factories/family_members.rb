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
FactoryBot.define do
  factory :family_member do
    user { nil }
    family { nil }
    visibility { Visibility::STAFF }
  end
end
