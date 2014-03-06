require 'spec_helper'

describe Admin::SchedulesController do
  render_views

  describe '#edit' do
    let(:tournament) { FactoryGirl.create(:tournament, :current) }
    let(:admin)  { FactoryGirl.create(:user, school: tournament.school) }

    subject { get :edit, id: schedule.slug }

    include_context 'as an admin of the tournament'

    context 'with a newly initialized schedule' do
      let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament, starttime: nil, endtime: nil) }

      it 'renders' do
        subject
        response.code.should == "200"
      end
    end

    context 'with a filled in schedule' do
      let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament) }

      it 'renders' do
        subject
        response.code.should == "200"
      end
    end
  end

  describe '#update' do
    let(:tournament) { FactoryGirl.create(:current_tournament) }
    let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament) }
    let(:num_timeslots) { 10 }
    let(:teams_per_slot) { 3 }

    include_context 'as an admin of the tournament'

    subject { post :update, params }

    context 'when creating timeslots' do
      let(:params) do
        {
          id: schedule.slug,
          schedule_online: 'true',
          schedule: {
            num_timeslots: num_timeslots.to_s,
            teams_per_slot: teams_per_slot.to_s,
          }
        }
      end

      it 'creates timeslots' do
        subject
        schedule.timeslots.count.should == num_timeslots
      end
    end

    context 'when switching back to fixed schedule' do
      before do
        FactoryGirl.create(:timeslot, schedule: schedule)
      end

      let(:params) do
        {
          id: schedule.slug,
          schedule_online: 'false'
        }
      end

      it 'removes timeslots' do
        subject
        schedule.timeslots.count.should == 0
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

  describe '#destroy' do
    let!(:tournament) { FactoryGirl.create(:current_tournament) }
    let!(:schedule)   { FactoryGirl.create(:schedule, :with_timeslots, tournament: tournament) }

    include_context 'as an admin of the tournament'

    subject { delete :destroy, id: schedule.slug }

    it 'deletes the schedule' do
      expect { subject }
        .to change { Schedule.count }
        .by(-1)
    end

    it 'deletes all associated timeslots' do
      id = schedule.id

      expect { subject }
        .to change { Timeslot.where(schedule_id: id).count }
        .to(0)
    end
  end
end
