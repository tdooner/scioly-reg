school = FactoryGirl.create(:school, subdomain: 'cwru')
FactoryGirl.create(:current_tournament, school: school)
