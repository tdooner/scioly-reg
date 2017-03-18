require 'spec_helper'

describe TimeslotsController do
  let(:tournament) { FactoryGirl.create(:current_tournament) }
  include_context 'as an admin of the tournament'

  describe '#create' do
    let(:schedule) do
      FactoryGirl.create(:schedule, tournament: tournament)
    end

    let(:params) do
      { timeslot_extra: { schedule: schedule },
        timeslot: {
          begins: Time.now,
          team_capacity: 5
      } }
    end

    it 'submits successfully' do
      expect { post :create, params }.to change { Timeslot.count }.by 1
    end
  end

  describe '#update' do
    let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament) }
    let!(:timeslot) { FactoryGirl.create(:timeslot, schedule: schedule) }
    let(:new_begin_time) { Time.now.in_time_zone(tournament.school.time_zone) }
    let(:new_team_capacity) { timeslot.team_capacity + 3 }

    let(:valid_params) do
      {
        id: timeslot.id,
        timeslot: {
          begins: new_begin_time,
          team_capacity: new_team_capacity
        }
      }
    end

    it 'updates' do
      post :update, valid_params

      timeslot.reload
      timeslot.begins.hour.should eq(new_begin_time.hour)
      timeslot.begins.min.should eq(new_begin_time.min)
      timeslot.begins.sec.should eq(new_begin_time.sec)
      timeslot.team_capacity.should == new_team_capacity
    end

    context 'when the admin cannot edit the timeslot' do
      before do
        User.any_instance.stubs(can_edit?: false)
      end

      it 'does not change the timeslot' do
        expect { post :update, valid_params }
          .not_to change { timeslot.reload.team_capacity }
      end
    end
  end
end
