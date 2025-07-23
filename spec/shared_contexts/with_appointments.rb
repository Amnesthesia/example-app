RSpec.shared_context 'with_appointments' do
  before do
    start_time = 2.days.from_now.beginning_of_day + 7.hours
    records = 10.times.map do |i|
      start_time += 30.minutes
      create(
        :appointment_guest,
        user: clients.sample,
        appointment: create(
          :appointment,
          owner: manager,
          organization: organization,
          start_time: start_time,
          end_time: start_time + 30.minutes
        )
      )
    end
    records += family.users.each_with_index.map do |user, index|
      start_time += 30.minutes
      create(
        :appointment_guest,
        user: user,
        appointment: build(
          :appointment,
          owner: manager,
          organization: organization,
          start_time: start_time,
          end_time: start_time + 30.minutes
        )
      )
    end
    records
  end
end