FactoryBot.define do
  factory :appointment do
    title { Faker::Lorem.sentence }
    start_time { 2.days.from_now }
    end_time { 2.days.from_now + 1.hour }
    organization { nil }
    state { 'scheduled' }
    owner { nil }
  end
end
