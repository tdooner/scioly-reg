require 'spec_helper'

describe Admin::TeamsController do
  context '#destroy' do
    let!(:team_tournament) { FactoryGirl.create(:current_tournament) }
    let!(:team) { FactoryGirl.create(:team, tournament: team_tournament) }

    include_context 'visiting a school' do
      let(:school) { team_tournament.school }
    end

    subject { post :destroy, id: team.id }

    it 'redirects home and does not delete anything' do
      expect { subject }.not_to change { Team.count }
      response.should redirect_to root_url
    end

    context 'as an admin' do
      include_context 'as an admin of the tournament'

      context 'of the correct tournament' do
        let(:tournament) { team_tournament }

        it 'deletes the team' do
          expect { subject }.to change { Team.count }.by(-1)
        end
      end

      context 'for a different tournament' do
        let!(:tournament) { FactoryGirl.create(:current_tournament) }

        it 'redirects home and does not delete anything' do
          expect { subject }.not_to change { Team.count }
          response.should redirect_to root_url
        end
      end
    end
  end

  describe '#batchcreate' do
    let(:team1_str) { "Nordonia High School\t13\tJohn Doe\tcoach@school.edu\tC\t211\tneur0n\n" }
    let(:team2_str) { "Nordonia High School 2\t14\tJohn Doe\tcoach@school.edu\tC\t211\tneur0n\n" }
    let(:params) { { batch: team1_str + team2_str } }
    let(:tournament) { FactoryGirl.create(:current_tournament) }

    subject { post :batchcreate, params }

    include_context 'as an admin of the tournament'

    it 'creates teams' do
      expect { subject }
        .to change { Team.count }.by(2)
    end

    it 'sets the right attributes' do
      subject

      team = Team.where(name: 'Nordonia High School').first
      team.number.should == "13"
      team.coach.should == 'John Doe'
      team.email.should == 'coach@school.edu'
      team.division.should == 'C'
      team.homeroom.should == "211"
      team.hashed_password.should == Team.encrypt('neur0n')
    end

    context 'when the same team is listed twice' do
      let(:params) { { batch: team1_str + team1_str } }

      it 'only creates the team once' do
        expect { subject }
          .to change { Team.count }.by(1)
      end
    end
  end

end
