require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
  def setup
    @current_school = FactoryGirl.create(:school)
    @other_school = FactoryGirl.create(:school)
    @current_tournament = FactoryGirl.create(:current_tournament, :school=>@current_school)
    FactoryGirl.create(:current_tournament, :school=>@other_school)
    5.times do
      FactoryGirl.create(:tournament, :school => @current_school)
      FactoryGirl.create(:tournament, :school => @other_school)
    end
  end

  test "Only one tournament is current in a given school." do
    assert @current_school.tournaments.select(&:is_current).length == 1
  end

  test "Changing one school's current tournament doesn't affect the other." do
    o = @other_school.tournaments.select(&:is_current)
    assert o.length == 1, "Multiple current tournaments!"
    @current_school.tournaments.select{|x| !x.is_current}.first.set_current
    assert o == @other_school.tournaments.select(&:is_current)
  end

  test "Show scores is false if a schedule has its scores withheld." do
    assert @current_tournament.update_attribute(:date, Time.now - 2.days), "Could not time travel tournament to the past."
    10.times do
      FactoryGirl.create(:schedule, :tournament => @current_tournament)
    end
    assert @current_tournament.show_scores?
    @current_tournament.schedules.shuffle.first.update_attribute(:scores_withheld, true)
    assert !@current_tournament.show_scores?
  end
end
