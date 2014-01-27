require 'spec_helper'

describe SchedulesController do
  render_views

  describe '#edit' do
    let(:tournament) { FactoryGirl.create(:tournament, :current) }
    let(:admin)  { FactoryGirl.create(:user, school: tournament.school) }

    subject { get :edit, id: schedule.id }

    before do
      request.host = "#{tournament.school.subdomain}.lvh.me"
      controller.stubs(session: { user_id: admin.id })
    end

    context 'with a newly initialized schedule' do
      let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament, starttime: nil, endtime: nil) }

      it 'renders' do
        subject
        response.code.should == "200"
      end
    end

    context 'with a filled in schedule' do
      let(:schedule) { FactoryGirl.create(:schedule) }

      it 'renders' do
        subject
        response.code.should == "200"
      end
    end
  end

  describe '#create' do
    let(:tournament) { FactoryGirl.create(:tournament, :current) }

    include_context 'as an admin of the tournament'

    context 'for a fixed schedule event' do
      let(:valid_params) do
        { schedule: {
            event: 'event name here',
            division: 'B',
            room: 'room',
            custom_info: 'any string',
            counts_for_score: true,
          },
          schedule_online: false
        }
      end

      it 'creates the event' do
        expect { post :create, valid_params }.to change { Schedule.count }.by(1)
      end
    end
  end
end
