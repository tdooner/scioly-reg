require 'spec_helper'

describe TeamsController do
  describe 'update action' do
    let(:tournament) { FactoryGirl.create(:current_tournament) }
    let(:team) { FactoryGirl.create(:team, :tournament => tournament) }

    before do
      request.host = "#{tournament.school.subdomain}.lvh.me"
    end

    context 'a logged in team' do
      before do
        controller.stubs(:session).returns(:team => team.id)
      end

      let(:form_data) do
        {
          'id' => team.id,
          'team' => {
            'coach' => 'ghijkl',
            'password' => 'new_password',
            'password_confirmation' => 'new_password',
          }
        }
      end

      context 'having confirmed their existing password' do
        let(:the_password) { 'something_that_I_can_hash' }

        before do
          team.update_attributes(
            :password => the_password,
            :password_confirmation => the_password,
          )
          form_data['team']['password_existing'] = the_password
        end

        it 'allows them to change the name of their coach' do
          post :update, form_data
          team.reload.coach.should == form_data['team']['coach']
        end

        it 'allows them to change their password' do
          post :update, form_data
          team.reload.hashed_password.should == Digest::SHA1.hexdigest(form_data['team']['password'])
        end

        it 'redirects to the login page' do
          post :update, form_data
          response.should redirect_to edit_team_url(team)
        end

        it 'does not permit a change to protected properties' do
          form_data['team']['division'] = 'D'
          expect { post :update, form_data }.
            to_not change { team.reload.division }
        end
      end

      context 'with the wrong password' do
        before do
          form_data['team']['password_existing'] = 'not_the_password'
        end

        it "doesn't accept a change" do
          expect { post :update, form_data }.
            to_not change { team.reload.coach }
        end
      end
    end

    context 'as an admin' do
      include_context 'as an admin of the tournament'

      let(:form_data) do
        {
          'id' => team.id,
          'team' => {
            'coach' => 'ghijkl',
            'division' => 'D',
          }
        }
      end

      it 'changes the password' do
        new_password = 'the_new_password'
        form_data['team']['password'] = new_password
        post :update, form_data
        team.reload.hashed_password.should == Digest::SHA1.hexdigest(new_password)
      end

      it 'changes protected attributes' do
        post :update, form_data
        team.reload.division.should == form_data['team']['division']
      end

      context "when send_email is not present" do
        it "doesn't send any email" do
          TeamMailer.expects(:password_update).never
          post :update, form_data
        end
      end

      context "when send_email is true" do
        it 'sends an email to the coach' do
          new_password = 'the_new_password'
          form_data['team']['password'] = new_password
          form_data['send_email'] = 'true'

          TeamMailer.expects(:password_update).with(team, new_password).returns(stub(:deliver => true))
          post :update, form_data
        end
      end
    end
  end

  context '#destroy' do
    let!(:team_tournament) { FactoryGirl.create(:current_tournament) }
    let!(:team) { FactoryGirl.create(:team, tournament: team_tournament) }

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
end
