organization = FactoryBot.create(:organization)
users_by_role = {}
%i[admin employee manager].each do |role|
  users_by_role[role] = FactoryBot.create(:user, role: role, organization: organization)
end

puts "Created organization: #{organization.name} (##{organization.id}) with a user for each role: #{users_by_role.keys.join(', ')}"

clients = FactoryBot.create_list(:user, 10, role: :client, organization: organization)
puts "Created #{clients.size} clients for organization: #{organization.name}"
family = FactoryBot.create(:family, generate_members: 5, organization: organization)
puts "Created family with #{family.users.size} members for organization: #{organization.name}"

start_time = 2.days.from_now.beginning_of_day + 7.hours
10.times.map do |i|
  start_time += 30.minutes
  FactoryBot.create(
    :appointment_guest,
    user: clients.sample,
    appointment: FactoryBot.create(
      :appointment,
      owner: users_by_role[:manager],
      organization: organization,
      start_time: start_time,
      end_time: start_time + 30.minutes
    )
  )
  puts "Created appointment for client ##{i + 1} at #{start_time}"
end
family.users.each_with_index.map do |user, index|
  start_time += 30.minutes
  FactoryBot.create(
    :appointment_guest,
    user: user,
    appointment: FactoryBot.build(
      :appointment,
      owner: users_by_role[:manager],
      organization: organization,
      start_time: start_time,
      end_time: start_time + 30.minutes
    )
  )
end