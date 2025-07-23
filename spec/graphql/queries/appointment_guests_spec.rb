require 'rails_helper'

RSpec.describe Resolvers::AppointmentGuests do
  include_context 'with_organization'
  include_context 'with_appointments'

  
  describe 'Querying appointments' do
    let(:query) do
      <<~GQL
      query AppointmentGuests {
        appointmentGuests {
          edges {
            node {
              id
              user {
                id
                name
              }
              
              appointment {
                id
                startTime
                endTime
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
        ).to_h.dig('data', 'appointmentGuests', 'edges').map { _1.dig('node') }
      end

      describe 'can see their own appointments' do
        it { is_expected.to have(family.users.first.appointments.reload.count).items }
        it { expect(subject.map { _1.dig('user', 'id') }.uniq).to eq([family.users.first.id.to_s]) }
      end

      describe 'can see visible family members appointments' do
        before do
          family.family_members.where.not(user: family.users.first).take(2).each do |family_member|
            family_member.update(visibility: 'staff_and_clients')
          end
        end

        it { is_expected.to have(Appointment.includes(:appointment_guests).where(appointment_guests: { user: family.users.first.with_family_members }).reload.count).items }
        it { expect(subject.map { _1.dig('user', 'id') }.uniq.sort).to eq(family.users.first.with_family_members.pluck(:id).map(&:to_s)) }
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
        ).to_h.dig('data', 'appointmentGuests', 'edges').map { _1.dig('node') }
      end
      describe 'can see all appointments' do
        it { is_expected.to have(Appointment.all.reload.count).items }
      end


      # This is where it gets weird ... it hits AppointmentGuestPolicy::Scope
      # for each item in the list, instead of diffing the list or filtering it
      describe 'should hit pundit scope ONCE' do
        before do
          @call_count = 0
          original_method = AppointmentGuestPolicy::Scope.instance_method(:resolve)
          allow_any_instance_of(AppointmentGuestPolicy::Scope).to receive(:resolve) do |instance, *args, &block|
            @call_count += 1
            original_method.bind(instance).call(*args, &block)
          end          
        end

        # This is kind of expected, it will call the scope for each appointment (although I wish this was cached...)
        it { is_expected.to have(15).items }
        it { expect { subject }.to change { @call_count }.to eq(2)  }
      end
    end
  end
end