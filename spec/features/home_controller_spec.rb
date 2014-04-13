require 'spec_helper'

describe 'the homepage' do
  context 'when visiting a tournament' do
    include_context '(capybara) visiting a tournament'

    it 'renders' do
      visit root_url
      expect(page).to have_content(@tournament.title)
    end
  end

  context 'when viewing the non-tournament homepage' do
    it 'renders' do
      visit root_url(subdomain: '')
      expect(page).to have_content('Use Foundry at Your School')
    end
  end
end
