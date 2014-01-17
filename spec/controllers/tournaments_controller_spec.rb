require 'spec_helper'

describe TournamentsController do
  describe '#destroy' do
    context 'with only one tournament' do
      let(:tournament) { FactoryGirl.create(:tournament, :current) }
      let(:admin) { FactoryGirl.create(:user, school: tournament.school) }

      before do
        request.host = "#{tournament.school.subdomain}.lvh.me"
        session[:user] = admin
      end

      it 'does not let you delete the tournament' do
        expect { delete :destroy, id: tournament.id }
          .not_to change { Tournament.count }
        response.should redirect_to tournaments_path
      end
    end

    context 'with multiple tournaments' do
      context 'when deleting the active tournament' do
        let!(:school) { FactoryGirl.create(:school) }
        let!(:old_tournament) { FactoryGirl.create(:tournament, school: school) }
        let!(:current_tournament) { FactoryGirl.create(:tournament, :current, school: school) }
        let!(:admin) { FactoryGirl.create(:user, school: school) }

        before do
          request.host = "#{school.subdomain}.lvh.me"
          session[:user] = admin
        end

        it 'sets a previous tournament as the active tournament' do
          expect { delete :destroy, id: current_tournament.id }
            .to change { Tournament.count }.by(-1)
          old_tournament.reload.is_current.should be_true
        end
      end
    end
  end
end
