require 'spec_helper'

describe Team do
  let(:tournament) { FactoryGirl.create(:tournament, :open_for_registration) }
  let(:team) { FactoryGirl.create(:team, tournament: tournament) }

  describe '#getNumber' do
    it 'returns a concatenation of the number and division' do
      team.getNumber.should == [team.number, team.division].join
    end
  end

  describe '.encrypt' do
    it 'uses SHA1' do
      Team.encrypt('a password').should ==
        '7847eb99571fc7a6728ad27bee9e7447db41d0a2'
    end
  end

  describe '#authenticate' do
    it 'finds a team given the id and the correct password' do
      Team.authenticate(team.id, team.password).should == team
    end

    it 'returns nil when team with that ID doesn\'t exist' do
      Team.authenticate(-1, team.password).should be_nil
    end

    it 'returns nil if the password is incorrect' do
      Team.authenticate(team.id, 'not_the_password').should be_nil
    end
  end

  describe 'can_register_for_event?' do
    context 'when the divisions and tournament match' do
      before do
        @schedule = FactoryGirl.create(:schedule,
                                       :division => team.division,
                                       :tournament => team.tournament)
      end

      subject { team.can_register_for_event?(@schedule) }
      it { should be_truthy }
    end

    context 'when the divisions differ' do
      before do
        @schedule = FactoryGirl.create(:schedule,
                                       :division => 'Z',
                                       :tournament => team.tournament)
      end

      subject { team.can_register_for_event?(@schedule) }
      it { should be_falsy }
    end

    context 'when the tournaments differ' do
      before do
        @other_tournament = FactoryGirl.create(:tournament)
        @schedule = FactoryGirl.create(:schedule,
                                       :division => team.division,
                                       :tournament => @other_tournament)
      end

      subject { team.can_register_for_event?(@schedule) }
      it { should be_falsy }
    end
  end

  describe '#unregistered_events' do
    let!(:schedule) do
      FactoryGirl.create(:schedule, :with_timeslots,
                         division: team.division,
                         tournament: team.tournament)
    end
    let!(:schedule_other_division) do
      FactoryGirl.create(:schedule, :with_timeslots,
                         division: (('A'..'Z').to_a - [team.division]).sample,
                         tournament: team.tournament)
    end
    let!(:schedule_no_timeslots) do
      FactoryGirl.create(:schedule, division: (('A'..'Z').to_a - [team.division]).sample,
                                    tournament: team.tournament)
    end

    context 'when the team has registered for no events' do
      it 'shows events in that teams division' do
        team.unregistered_events.should include(schedule)
      end

      it 'excludes events not in the same division' do
        team.unregistered_events.should_not include(schedule_other_division)
      end

      it 'excludes events without timeslots' do
        team.unregistered_events.should_not include(schedule_no_timeslots)
      end
    end

    context 'when the team has registered for an event' do
      let!(:other_schedule) do
        FactoryGirl.create(:schedule, :with_timeslots,
                           division: team.division,
                           tournament: team.tournament)
      end
      let!(:timeslot) { FactoryGirl.create(:timeslot, schedule: schedule) }
      let!(:signup) { FactoryGirl.create(:sign_up, timeslot: timeslot, team: team) }

      it "doesn't include that event in the list" do
        team.unregistered_events.should_not include(schedule)
      end

      context 'when the timeslot has been deleted' do
        before do
          signup.timeslot.delete # intentionally disregard callbacks
        end

        it 'returns something sensible (all the events)' do
          team.unregistered_events.should include(schedule)
          team.unregistered_events.should include(other_schedule)
        end
      end
    end
  end
end
