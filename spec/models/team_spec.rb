require 'spec_helper'

describe Team do
  before do
    @team = FactoryGirl.create(:team)
  end

  describe '#getNumber' do
    it 'returns a concatenation of the number and division' do
      @team.getNumber.should == [@team.number, @team.division].join
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
      Team.authenticate(@team.id, @team.password).should == @team
    end

    it 'returns nil when team with that ID doesn\'t exist' do
      Team.authenticate(-1, @team.password).should be_nil
    end

    it 'returns nil if the password is incorrect' do
      Team.authenticate(@team.id, 'not_the_password').should be_nil
    end
  end

  describe 'can_register_for_event?' do
    context 'when the divisions and tournament match' do
      before do
        @schedule = FactoryGirl.create(:schedule,
                                       :division => @team.division,
                                       :tournament => @team.tournament)
      end

      subject { @team.can_register_for_event?(@schedule) }
      it { should be_true }
    end

    context 'when the divisions differ' do
      before do
        @schedule = FactoryGirl.create(:schedule,
                                       :division => 'Z',
                                       :tournament => @team.tournament)
      end

      subject { @team.can_register_for_event?(@schedule) }
      it { should be_false }
    end

    context 'when the tournaments differ' do
      before do
        @other_tournament = FactoryGirl.create(:tournament)
        @schedule = FactoryGirl.create(:schedule,
                                       :division => @team.division,
                                       :tournament => @other_tournament)
      end

      subject { @team.can_register_for_event?(@schedule) }
      it { should be_false }
    end
  end
end
