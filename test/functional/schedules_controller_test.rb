require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  def setup
    Schedule.delete_all()
    @current_tournament = FactoryGirl.create(:current_tournament)
    @other_tournament = FactoryGirl.create(:tournament)
    20.times do |i|
      FactoryGirl.create(:schedule,{:event=>"event current #{i}",:tournament=>@current_tournament})
      FactoryGirl.create(:schedule,{:event=>"event other #{i}", :tournament=>@other_tournament})
    end
  end

  test "Dropdown whilst logged out" do
    visit '/'
    @current_tournament.schedules.each do |i|
      assert page.has_content?(i.event), "Event is missing!"
    end
    @other_tournament.schedules.each do |i|
      assert !page.has_content?(i.event), "Other tournament's event shows up!"
    end
  end
end
