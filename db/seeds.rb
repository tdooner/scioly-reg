school = FactoryGirl.create(:school,
                            name: 'Case Western Reserve University',
                            subdomain: 'cwru'
                           )

tournament = FactoryGirl.create(:current_tournament,
                                title: 'Northeast Ohio Science Olympiad',
                                school: school)

Tournament::AVAILABLE_DIVISIONS.each do |division|
  10.times do
    FactoryGirl.create(:default_event, division: division, year: Time.now.year)
  end
end

tournament.load_default_events

tournament.divisions.each do |division|
  30.times do
    FactoryGirl.create(:team, division: division, tournament: tournament)
  end
end
