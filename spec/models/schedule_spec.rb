require 'spec_helper'

describe Schedule do
  before do
    @schedule = FactoryGirl.create(:schedule)
  end

  describe '#updateTimeSlots' do
    let(:num_timeslots) { 10 }
    let(:teams_per_slot) { 3 }

    context 'when not given a number of timeslots' do
      it 'returns an error' do
        @schedule.updateTimeSlots.should include('Error')
      end
    end

    context 'when given a number of timeslots' do
      before do
        @schedule.num_timeslots = num_timeslots
      end

      context 'when given a number of teams per timeslot' do
        before do
          @schedule.teams_per_slot = teams_per_slot
          @schedule.updateTimeSlots
        end

        it 'should be idempotent' do
          @timeslots = @schedule.timeslots
          @schedule.updateTimeSlots

          @schedule.timeslots.reload.should == @timeslots
        end

        it 'should create the correct number of timeslots' do
          @schedule.timeslots.length.should == num_timeslots
        end

        it 'should create timeslots that have the correct number of teams' do
          @schedule.timeslots.all? { |t| t.team_capacity == teams_per_slot }.
            should be_true
        end

        it 'produces timeslots only within the start and end times' do
          @schedule.timeslots.all? do |t|
            t.begins >= @schedule.starttime && t.ends <= @schedule.endtime
          end.should be_true
        end
      end

      context 'when not given a number of teams per timeslot' do
        before do
          @schedule.updateTimeSlots
        end

        it 'defaults to one team per timeslot' do
          @schedule.timeslots.all? { |t| t.team_capacity == 1 }.should be_true
        end
      end
    end

    context 'when timeslots already exist for the event' do
      before do
        @schedule.num_timeslots = num_timeslots
        @schedule.teams_per_slot = teams_per_slot
        @schedule.updateTimeSlots
      end

      it 'removes unused timeslots' do
        @schedule.num_timeslots = num_timeslots - 2
        expect { @schedule.updateTimeSlots }.to change { Timeslot.count}.by -2
      end
    end
  end

  describe '#hasTeamRegistered' do
    let(:team) { FactoryGirl.create(:team, :tournament => @schedule.tournament) }

    context 'when the team has registered for the event' do
      before do
        @schedule.num_timeslots = 10
        @schedule.updateTimeSlots
        Timecop.freeze(@schedule.tournament.registration_begins + 2.minutes) do
          @sign_up = FactoryGirl.create(:sign_up,
                                    :team => team,
                                    :timeslot => @schedule.timeslots.sample)
        end
      end

      subject { @schedule.hasTeamRegistered(team) }
      it { should be_true }
    end

    context 'when the team has not registered for the event' do
      before do
        @schedule.num_timeslots = 10
        @schedule.updateTimeSlots
      end

      subject { @schedule.hasTeamRegistered(team) }
      it { should be_false }
    end
  end

  describe '#default_timeslots?' do
    before do
      @schedule.num_timeslots = 10
      @schedule.updateTimeSlots
    end

    context 'when no customizations to timeslots have occurred' do
      subject { @schedule.default_timeslots? }
      it { should be_true }
    end

    context 'when one timeslot has a different team capacity' do
      before do
        @schedule.timeslots.sample.update_attribute(:team_capacity, 500)
      end

      subject { @schedule.default_timeslots? }
      it { should be_false }
    end

    context 'when a timeslot has been removed' do
      before do
        @schedule.timeslots.sample.delete
      end

      subject { @schedule.default_timeslots? }
      it { should be_false }
    end

    context 'when a timeslot has been added' do
      before do
        FactoryGirl.create(:timeslot, :schedule => @schedule)
      end

      subject { @schedule.default_timeslots? }
      it { should be_false }
    end
  end
end
