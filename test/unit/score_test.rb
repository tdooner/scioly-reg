require 'test_helper'

class ScoreTest < ActiveSupport::TestCase
  def setup 
    @current_school = FactoryGirl.create(:school)
    @current_tournament = FactoryGirl.create(:current_tournament, :occurred, :school => @current_school)
    10.times do |t|
      FactoryGirl.create(:team, :tournament => @current_tournament)
      FactoryGirl.create(:schedule, :tournament => @current_tournament)
    end
  end

  test "Scores save for an event." do
    scores = (1..@current_tournament.teams.length).to_a.shuffle
    schedule = @current_tournament.schedules.first
    scores.each_with_index do |i,s|
      assert Score.new({:schedule => schedule, :team => @current_tournament.teams[i], :placement => s}).save
    end
  end

  test "Scores are invalid without an event, team, or placement value" do
    schedule = @current_tournament.schedules.first
    team = @current_tournament.teams.first
    score = 6 # Arbitrary values.
    assert !Score.new({:team => team, :placement => score}).save, "Score saved without an event!"
    assert !Score.new({:schedule => schedule, :placement => score}).save, "Score saved without a team!"
    assert !Score.new({:schedule => schedule, :team => team}).save, "Score saved without a placement!"
  end

  test "No team can have two score entries for an event." do
    schedule = @current_tournament.schedules.first
    team = @current_tournament.teams.first
    scores = [5, 6] # Arbitrary values.
    assert Score.new({:schedule => schedule, :team => team, :placement => scores[0]}).save
    assert !Score.new({:schedule => schedule, :team => team, :placement => scores[1]}).save
  end

  test "A placement is invalid if it is three greater than the number of teams." do
    schedule = @current_tournament.schedules.first
    team = @current_tournament.teams.first
    assert !Score.new({:schedule => schedule, :team => team, :placement => @current_tournament.teams.length+3}).save  
  end

  test "A placement is invalid if it is zero or negative." do
    schedule = @current_tournament.schedules.first
    team = @current_tournament.teams.first
    assert !Score.new({:schedule => schedule, :team => team, :placement => 0}).save  
    assert !Score.new({:schedule => schedule, :team => team, :placement => -1}).save  
    assert !Score.new({:schedule => schedule, :team => team, :placement => -2}).save  
  end

  test "Deleting an event's placements removes the entries from the database." do
    # Add scores for all teams in one event
    scores = (1..@current_tournament.teams.length).to_a.shuffle
    schedule = @current_tournament.schedules.first
    scores.each_with_index do |i,s|
      assert Score.new({:schedule => schedule, :team => @current_tournament.teams[i], :placement => s}).save
    end
    num_before = Score.all.length

    # Delete them!
    assert schedule.scores.delete_all
    assert schedule.scores.empty?
    assert (num_before - Score.all.length) == scores.length
  end
end
