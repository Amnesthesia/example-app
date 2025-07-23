RSpec.shared_context 'with_organization' do
  let(:organization) { create(:organization) }

  %i[admin employee manager].each do |role|
    let(role) { create(:user, role: role, organization: organization) }
  end

  let(:clients) { create_list(:user, 10, role: :client, organization: organization)}

  10.times do |i|
    let("client#{i + 1}".to_sym) { clients[i] }
  end

  let(:family) { create(:family, generate_members: 5, organization: organization) }
end