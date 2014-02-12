require 'spec_helper'

describe SignupsController do
  describe '#destroy' do
    let!(:tournament) { FactoryGirl.create(:current_tournament, :open_for_registration) }
    let!(:schedule)   { FactoryGirl.create(:schedule, :with_timeslots, tournament: tournament) }
    let!(:team)       { FactoryGirl.create(:team, tournament: tournament) }
    let!(:signup)     { FactoryGirl.create(:sign_up, timeslot: schedule.timeslots.sample, team: team) }

    subject { delete :destroy, id: signup.id }

    context 'as the intended team' do
      before do
        request.host = "#{tournament.school.subdomain}.lvh.me"
        session[:team] = team.id
      end

      it 'deletes the signup' do
        expect { subject }
          .to change { SignUp.count }
          .by(-1)
      end

      it 'redirects to the schedule page' do
        subject.should redirect_to schedule_url(signup.timeslot.schedule)
      end
    end

    context 'as another team' do
      let(:other_team) { FactoryGirl.create(:team, tournament: tournament) }

      before do
        session[:team] = other_team.id
      end

      it "doesn't delete the signup" do
        expect { subject }
          .not_to change { SignUp.count }
      end
    end
  end
end
