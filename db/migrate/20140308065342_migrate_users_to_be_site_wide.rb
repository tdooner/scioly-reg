class MigrateUsersToBeSiteWide < ActiveRecord::Migration
  def up
    # create administrations for things that already exist
    School.all.each do |school|
      User.where(school_id: school.id).each do |user|
        Administration.create(user: user, administrates: school)
      end
    end

    # create new user records
    Tournament.all.each do |tournament|
      tournament.teams.each do |team|
        next unless team.email && team.email.include?('@')

        u = User.where(email: team.email)
            .first_or_create(hashed_password: team.hashed_password)

        # use the most recent password
        u.update_attributes(hashed_password: team.hashed_password)

        Administration.create(user: u, administrates: team)
      end
    end

    # deduplicate existing user records
    duplicates = User.group(:email).having('count_all > 1').count.keys
    duplicates.each do |email|
      users = User.where(email: email)
      original = users.shift

      users.each do |duplicate_user|
        Administration.create(user: original,
                              administrates: School.find(duplicate_user.school_id))
        original.update_attributes(hashed_password: duplicate_user.hashed_password)
        duplicate_user.destroy
      end
    end

    remove_column :users, :school_id
    remove_column :users, :role
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
