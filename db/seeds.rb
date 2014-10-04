school = FactoryGirl.create(:school,
                            name: 'Case Western Reserve University',
                            subdomain: 'cwru'
                           )

tournament = FactoryGirl.create(:current_tournament,
                                title: 'Northeast Ohio Science Olympiad',
                                school: school)

# create events:
Tournament::AVAILABLE_DIVISIONS.each do |division|
  10.times do
    FactoryGirl.create(:default_event, division: division, year: Time.now.year)
  end
end

tournament.load_default_events

# create teams:
tournament.divisions.each do |division|
  30.times do
    team = FactoryGirl.create(:team, division: division, tournament: tournament)

    # gratuitously make two coaches for each team:
    2.times do
      coach = FactoryGirl.create(:user)
      Administration.create(user: coach, administrates: team)
    end
  end
end
