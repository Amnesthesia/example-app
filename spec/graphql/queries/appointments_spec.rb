require 'rails_helper'

RSpec.describe Resolvers::Appointments do
  include_context 'with_organization'
  include_context 'with_appointments'

  
  describe 'Querying appointments' do
    let(:query) do
      <<~GQL
      query Appointments($timeRange: TimeRangeInput!) {
        appointments(timeRange: $timeRange) {
          edges {
            node {
              id
              startTime
              endTime
  
              appointmentGuests {
                id
                user {
                  id
                  name
                }
              }
            }
          }
        }
      }
      GQL
    end
    context 'as a client' do

      subject do
        ExampleappSchema.execute(
          query,
          variables: {
            timeRange: {
              start: DateTime.current.iso8601,
              end: (DateTime.current + 1.month).iso8601
            }
          },
          context: {
            current_user: Pundit::User.new(family.users.first),
            pundit_user: Pundit::User.new(family.users.first),
          }
        ).to_h.dig('data', 'appointments', 'edges').map { _1.dig('node') }
      end

      describe 'can see their own appointments' do
        it { is_expected.to have(family.users.first.appointments.reload.count).items }
        it { expect(subject.map { _1.dig('appointmentGuests', 0, 'user', 'id') }.uniq).to eq([family.users.first.id.to_s]) }
      end

      describe 'can see visible family members appointments' do
        before do
          family.family_members.where.not(user: family.users.first).take(2).each do |family_member|
            family_member.update(visibility: 'staff_and_clients')
          end
        end

        it { is_expected.to have(Appointment.includes(:appointment_guests).where(appointment_guests: { user: family.users.first.with_family_members }).reload.count).items }
        it { expect(subject.map { _1.dig('appointmentGuests', 0, 'user', 'id') }.uniq.sort).to eq(family.users.first.with_family_members.pluck(:id).map(&:to_s)) }
      end
    end

    context 'as a staff member' do
      subject do
        ExampleappSchema.execute(
          query,
          variables: {
            timeRange: {
              start: DateTime.current.iso8601,
              end: (DateTime.current + 1.month).iso8601
            }
          },
          context: {
            pundit_user: Pundit::User.new(manager),
            current_user: Pundit::User.new(manager)
          }
        ).to_h.dig('data', 'appointments', 'edges').map { _1.dig('node') }
      end
      describe 'can see all appointments' do
        it { is_expected.to have(Appointment.all.reload.count).items }
      end
      # This is where it gets weird ... it hits the Appointment policy once,
      # but then it hits the AppointmentGuest Policy Scope once for EVERY guest
      describe 'should hit pundit scope ONCE' do

        it { expect_any_instance_of(AppointmentPolicy::Scope).to receive(:resolve).once.and_call_original; subject; }

        # This is kind of expected, it will call the scope for each appointment (although I wish this was cached...)
        it { expect_any_instance_of(AppointmentGuestPolicy::Scope).to receive(:resolve).once.and_call_original; subject; }
      end
    end
  end
end