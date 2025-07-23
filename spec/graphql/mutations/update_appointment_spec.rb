require 'rails_helper'

RSpec.describe Resolvers::Appointments do
  include_context 'with_organization'
  include_context 'with_appointments'

  let(:appointment) { Appointment.first }

  
  describe 'Querying appointments' do
    let(:mutation) do
      <<~GQL
      mutation UpdateAppointment($id: ID!, $timeRange: TimeRangeInput!) {
        updateAppointment(input: { id: $id, timeRange: $timeRange }) {
          appointment {
            id
            title
            startTime
            endTime
          }
        }
      }
      GQL
    end

    context 'as a staff member' do
      
      subject do
        ExampleappSchema.execute(
          mutation,
          variables: {
            id: appointment.id.to_s,
            timeRange: {
              start: 10.days.from_now.iso8601,
              end: (10.days.from_now + 30.minutes).iso8601
            }
          },
          context: {
            pundit_user: Pundit::User.new(manager),
            current_user: Pundit::User.new(manager)
          }
        ).to_h.dig('data', 'updateAppointment', 'appointment')
      end
      
      describe 'appointment is updated' do
        it { expect { subject }.to change { appointment.reload.start_time } }
        it { expect { subject }.to change { appointment.reload.end_time } }
        it { is_expected.to include_json(id: appointment.id.to_s, title: appointment.title.to_s) }
      end

      describe 'authorizes with pundit' do
        it { expect_any_instance_of(Types::Base::Argument).to receive(:authorized?) }
      end
    end

    context 'as a client' do

      subject do
        ExampleappSchema.execute(
          mutation,
          variables: {
            id: appointment.id.to_s,
            timeRange: {
              start: DateTime.current.iso8601,
              end: (DateTime.current + 1.month).iso8601
            }
          },
          context: {
            current_user: Pundit::User.new(family.users.first),
            pundit_user: Pundit::User.new(family.users.first),
          }
        ).to_h.dig('data', 'updateAppointment', 'appointment')
      end

      describe 'appointment can not be updated' do
        it { expect { subject }.to change { appointment.reload.start_time } }
        it { expect { subject }.to change { appointment.reload.end_time } }
        it { is_expected.to include_json(id: appointment.id.to_s, title: appointment.title.to_s) }
      end
    end
  end
end