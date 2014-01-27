require 'spec_helper'

describe 'the schedule signup process' do
  include_context '(capybara) as a logged in team' do
    let(:registration_begins) { Time.now - 1.day }
    let(:registration_ends) { Time.now + 1.day }
  end

  context 'with an event on that tournament' do
    let!(:event) do
      FactoryGirl.create(:schedule, tournament: @tournament,
                                    division: @team.division)
    end

    let!(:timeslot) do
      FactoryGirl.create(:timeslot, schedule: event)
    end

    it 'shows a list of events you can register for' do
      visit division_schedules_url(@team.division)
      within '#contentWrapper' do
        click_link event.humanize
      end
      click_link 'Register!'
      click_link 'Reserve This Slot!'
      expect(page).to have_content("Your team is registered in the #{timeslot.begins.strftime("%I:%M %p")} timeslot")
    end
  end
end
