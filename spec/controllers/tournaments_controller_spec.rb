require 'spec_helper'

describe TournamentsController do
  render_views

  shared_context 'as an admin of the tournament' do
    let(:admin) { FactoryGirl.create(:user, school: tournament.school) }

    before do
      request.host = "#{tournament.school.subdomain}.lvh.me"
      session[:user_id] = admin.id
    end
  end

  describe '#destroy' do
    context 'with only one tournament' do
      let(:tournament) { FactoryGirl.create(:tournament, :current) }

      include_context 'as an admin of the tournament'

      it 'does not let you delete the tournament' do
        expect { delete :destroy, id: tournament.id }
          .not_to change { Tournament.count }
        response.should redirect_to tournaments_path
      end
    end

    context 'with multiple tournaments' do
      let(:school) { FactoryGirl.create(:school) }
      let!(:old_tournament) { FactoryGirl.create(:tournament, school: school) }
      let!(:current_tournament) { FactoryGirl.create(:tournament, :current, school: school) }

      include_context 'as an admin of the tournament' do
        let(:tournament) { current_tournament }
      end

      context 'when deleting the active tournament' do
        it 'sets a previous tournament as the active tournament' do
          expect { delete :destroy, id: current_tournament.id }
            .to change { Tournament.count }.by(-1)
          old_tournament.reload.is_current.should be_true
        end
      end
    end
  end

  describe '#set_active' do
    context 'with a non-current tournament' do
      include_context 'as an admin of the tournament'

      let(:tournament) { FactoryGirl.create(:tournament, :current) }
      let(:other_tournament) { FactoryGirl.create(:tournament) }

      subject { post :set_active, current: other_tournament }

      it 'sets it to current' do
        subject
        other_tournament.reload.should be_current
        response.should redirect_to tournaments_path
      end
    end
  end
end
