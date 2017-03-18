require 'spec_helper'

describe SchedulesController do
  describe '#show' do
    render_views

    let(:tournament) { FactoryGirl.create(:tournament, :current) }
    let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament) }

    before do
      request.host = "#{tournament.school.subdomain}.lvh.me"
    end

    describe 'with a timeslot' do
      let!(:timeslot) do
        # currently the timeslots are stored as UTC and then we rely on
        # Time.zone to convert them back for display
        #
        # So for a 14:00 timeslot in EST (UTC-5), the database would have 19:00.
        begins = Time.new(2017, 2, 1, 14, 0, 0, 0)
        ends = Time.new(2017, 2, 1, 16, 0, 0, 0)

        FactoryGirl.create(:timeslot, schedule: schedule, begins: begins, ends: ends)
      end

      subject { get :show, id: schedule.id }

      it 'uses the literal time zone value' do
        subject

        # sanity check the time zone
        expect(timeslot.begins.utc_offset).to eq(0)
        begins_human = timeslot.begins.strftime("%I:%M %p")

        timeslot_table = Nokogiri::HTML(response.body).xpath('//table[@id="timeslot"]')
        expect(timeslot_table.text).to include(begins_human)
        expect(timeslot_table.text).to include('2:00 PM')
      end
    end

    describe 'when requesting a PDF' do
      subject { get :show, id: schedule.id, format: 'pdf' }

      it 'redirects as a normal user' do
        subject
        response.should redirect_to schedule_path(schedule.id)
      end

      context 'as an admin' do
        include_context 'as an admin of the tournament'

        it 'calls render with :pdf' do
          controller.stubs(:render)
          controller.expects(:render).with(has_key(:pdf)).once
          subject
        end
      end
    end
  end

  describe '#edit' do
    render_views

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

  describe '#update' do
    render_views

    let(:tournament) { FactoryGirl.create(:current_tournament) }
    let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament) }
    let(:num_timeslots) { 10 }
    let(:teams_per_slot) { 3 }

    include_context 'as an admin of the tournament'

    subject { post :update, params }

    context 'when creating timeslots' do
      let(:params) do
        {
          id: schedule.id,
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
          id: schedule.id,
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
    render_views

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
    render_views

    let!(:tournament) { FactoryGirl.create(:current_tournament) }
    let!(:schedule)   { FactoryGirl.create(:schedule, :with_timeslots, tournament: tournament) }

    include_context 'as an admin of the tournament'

    subject { delete :destroy, id: schedule.id }

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
