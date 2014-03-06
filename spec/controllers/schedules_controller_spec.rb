require 'spec_helper'

describe SchedulesController do
  let!(:tournament) { FactoryGirl.create(:tournament, :current) }
  let!(:schedule)   { FactoryGirl.create(:schedule, tournament: tournament) }

  render_views

  include_context 'visiting a school' do
    let(:school) { tournament.school }
  end

  describe '#index' do
    context 'when logged in as a team' do
      include_context 'as a team in the tournament'

      it 'renders' do
        get :index
        response.should be_success
      end
    end

    it 'renders' do
      get :index
      response.should be_success
    end
  end

  describe '#show' do
    context 'when logged in as a team' do
      include_context 'as a team in the tournament'

      it 'renders' do
        get :show, id: schedule.slug
        response.should be_success
      end
    end

    it 'renders' do
      get :show, id: schedule.slug
      response.should be_success
    end
  end
end

