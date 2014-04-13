require 'spec_helper'

describe SchedulesController do
  let!(:tournament) { FactoryGirl.create(:tournament, :current) }
  let!(:schedule)   { FactoryGirl.create(:schedule, tournament: tournament) }

  describe '#show' do
    render_views

    context 'when logged in as a team' do
      include_context 'as a team in the tournament'

      describe 'when requesting a PDF' do
        before do
          # Don't actually try to render the PDF since that executable differs
          # by platform and is slow.
          controller.stubs(:render)
        end

        subject { get :show, id: schedule, format: 'pdf' }

        it 'redirects as a normal user' do
          controller.expects(:render).never
          subject
          response.should redirect_to schedule_path(schedule.to_param)
        end

        context 'as an admin' do
          include_context 'as an admin of the tournament'

          it 'calls render with :pdf' do
            controller.expects(:render).with(has_key(:pdf)).once
            subject
          end
        end
      end
    end
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
end
