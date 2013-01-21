describe Tournament do
  describe '#set_current' do
    let!(:school) { FactoryGirl.create(:school) }
    let!(:tournament) { FactoryGirl.create(:tournament, :school => school) }
    let!(:current_tournament) { FactoryGirl.create(:current_tournament, :school => school) }
    let!(:current_tournament_at_another_school) do
      FactoryGirl.create(:current_tournament)
    end

    it 'sets the desired tournament to active' do
      tournament.set_current
      tournament.reload.is_current.should be_true
    end

    it 'sets other tournaments at the same school to inactive' do
      tournament.set_current
      current_tournament.reload.is_current.should be_false
    end

    it "doesn't change tournaments for other schools" do
      tournament.set_current
      current_tournament_at_another_school.is_current.should be_true
    end
  end
end
