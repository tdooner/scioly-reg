require 'spec_helper'

describe SchedulesController do
  render_views

  describe '#edit' do
    let(:tournament) { FactoryGirl.create(:tournament, :current) }
    let(:admin)  { FactoryGirl.create(:user, school: tournament.school) }

    subject { get :edit, id: schedule.id }

    before do
      request.host = "#{tournament.school.subdomain}.lvh.me"
      controller.stubs(session: { user: admin })
    end

    context 'with a newly initialized schedule' do
      let(:schedule) { FactoryGirl.create(:schedule, tournament: tournament, starttime: nil, endtime: nil) }

      it 'renders' do
        subject
        response.code.should == "200"
      end
    end

    context 'with a filled in schedule' do
      let(:schedule) { FactoryGirl.create(:schedule) }

      it 'renders' do
        subject
        response.code.should == "200"
      end
    end
  end
end
