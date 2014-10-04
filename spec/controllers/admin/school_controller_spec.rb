require 'spec_helper'

describe Admin::SchoolController do
  render_views

  let(:tournament) { FactoryGirl.create(:current_tournament) }
  let(:school)     { tournament.school }

  describe '#update' do
    include_context 'as an admin of the tournament'

    let(:valid_form) do
      { school: {
          admin_name: 'New Admin Name',
          admin_email: 'New Admin Email',
          time_zone: 'Pacific Time (US & Canada)',
        },
        new_user: '',
        new_user_password: '',
        new_user_password_confirmation: '',
      }
    end

    subject { patch :update, params }

    context 'without the logged-in admin password' do
      let(:params) { valid_form }

      it "doesn't update the attributes" do
        expect { subject }.not_to change { school.reload.admin_name }
      end

      it 'redirects to the same page' do
        subject.should redirect_to admin_school_edit_url
      end
    end

    context 'with the correct admin password' do
      let(:valid_form) { super().merge(current_password: admin_password) }
      let(:params)     { valid_form }

      it 'updates the attributes' do
        expect { subject }
          .to change { school.reload.admin_name }
          .to(valid_form[:school][:admin_name])
      end

      it "doesn't create a new user" do
        expect { subject }
          .not_to change { User.count }
      end

      context 'when given new_user params' do
        let(:params) do
          valid_form.merge(new_user: 'new_user@example.com',
                           new_user_password: 'password',
                           new_user_password_confirmation: 'password')
        end

        it 'creates a valid new user' do
          expect { subject }
            .to change { User.count }.by(1)

          User.authenticate(school,
                            params[:new_user],
                            params[:new_user_password]).should be_a(User)
        end
      end

      context 'when given delete params' do
        xit 'deletes the user'
      end
    end
  end
end
