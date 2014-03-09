namespace :sandbox do
  desc 'Reset the sandbox instance'
  task reset: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    ActiveRecord::Base.transaction do
      School.where(subdomain: 'sandbox').destroy_all
      User.where(email: 'test@example.com').destroy_all
      school = School.create(
        name: 'Sandbox University',
        subdomain: 'sandbox',
        admin_name: 'Test Admin',
        admin_email: 'test@example.com',
      )

      tournament = Tournament.create(
        school: school,
        divisions: ['B', 'C'],
        title: 'Sandbox Testing Tournament',
        is_current: true,
        date: Date.today + 3.weeks,
        registration_begins: Date.yesterday,
        registration_ends: Date.today + 1.week,
        homepage_markdown: "Log in with test@example.com / password",
      )
      tournament.load_default_events(2013)

      user = User.create(
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password'
      )
      Administration.create(
        user: user,
        administrates: school
      )
    end
  end
end
