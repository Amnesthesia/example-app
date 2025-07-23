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
FactoryBot.define do
  factory :family do
    name { Faker::Name.last_name }

    transient do
      generate_members { [5, {}] }
    end

    after(:create) do |family, evaluator|
      member_count, extr_attrs = [evaluator.generate_members || [5, {}]].flatten
      member_count.times do
        create(:user, role: :client, organization: family.organization).tap do |user|
          create(:family_member, user: user, family: family, **extr_attrs)
        end
      end
    end
  end
end
