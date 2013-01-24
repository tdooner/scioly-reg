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

    context 'an admin' do
      before do
        controller.stubs(:session).returns(:user => FactoryGirl.build(:user))
        User.any_instance.stubs(:is_admin_of).returns(true)
      end

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
    end
  end
end

