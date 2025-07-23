# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string
#  encrypted_password :string
#  password_digest    :string
#  role               :string
#  organization_id    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { Digest::MD5.hexdigest(SecureRandom.hex(8)) }
    role { Role.list.sample }
  end
end
