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
    end
  end
end
