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
require 'rails_helper'

RSpec.describe User, type: :model do
  include_context 'with_organization'

  context 'with staff role' do
    describe 'can always see all their family members' do
      before { family.family_members.find_or_create_by(user: employee) }
      subject { employee.with_family_members }

      it { expect(employee).to have_attributes(role: 'employee') }
      it { is_expected.to include(employee) }
      it { is_expected.to have().items }
    end
  end

  context 'with client role' do
    describe 'can only see family members with visibility set to staff_and_clients' do
      let(:family_user) { family.users.first }
      let(:household) { family_user.household }
      subject { family_user.with_family_members }

      it { is_expected.to include(family.users.first) }
      it { is_expected.to have(1).items }
    end
  end
end
