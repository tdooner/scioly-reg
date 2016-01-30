require 'spec_helper'

describe TournamentsController do
  render_views

  describe '#new' do
    let(:tournament) { FactoryGirl.create(:tournament, :current) }

    subject { get :new }

    include_context 'as an admin of the tournament'

    it 'renders' do
      subject
      expect(response).to be_success
    end

    it 'offers to copy the schedule' do
      subject
      expect(response.body).to match(/copy schedule/i)
    end
  end

  describe '#create' do
    let(:tournament) { FactoryGirl.create(:tournament, :current) }
    include_context 'as an admin of the tournament'

    let(:params) do
      {
        'tournament' => {
          'date' => '2016-01-01',
          'registration_begins' => '2015-12-01 00:00:00',
          'registration_ends' => '2015-12-15 00:00:00',
        }
      }
    end

    subject { post :create, params }

    it 'creates the tournament' do
      expect { subject }
        .to change { Tournament.count }.by(1)
    end

    describe 'with copy_tournament_id' do
      let(:params) { super().tap { |p| p['copy_tournament_id'] = tournament.id } }
      let!(:schedules) do
        5.times.map { FactoryGirl.create(:schedule, tournament: tournament, scores_withheld: true) }
      end

      it 'copies the schedules to the new tournament' do
        subject
        new_tournament = assigns(:tournament)
        expect(new_tournament.schedules.length).to eq(tournament.schedules.length)
        expect(new_tournament.schedules).to be_none(&:scores_withheld)
      end
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

  describe '#update' do
    let(:tournament) { FactoryGirl.create(:tournament, :current) }
    let(:new_title) { 'lololol' }
    let(:new_homepage) { 'hahaha' }
    let(:update_params) do
      { id: tournament.id,
        tournament: { title: new_title, homepage_markdown: new_homepage }
      }
    end

    include_context 'as an admin of the tournament'

    it 'updates successfully' do
      post :update, update_params
      tournament.reload.title.should == new_title
      tournament.reload.homepage_markdown.should == new_homepage
    end
  end

  describe '#set_active' do
    context 'with a non-current tournament' do
      include_context 'as an admin of the tournament'

      let(:tournament) { FactoryGirl.create(:tournament, :current) }
      let(:other_tournament) { FactoryGirl.create(:tournament) }

      subject { post :set_active, current: other_tournament.id }

      it 'sets it to current' do
        subject
        other_tournament.reload.should be_current
        response.should redirect_to tournaments_path
      end
    end

    context 'with an already current tournament' do
      include_context 'as an admin of the tournament'

      let(:tournament) { FactoryGirl.create(:current_tournament) }

      subject { post :set_active, current: tournament.id }

      it 'keeps the tournament as current' do
        expect { subject }.not_to change { tournament.reload.current? }
      end
    end
  end
end
