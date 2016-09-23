ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.mailgun.org',
  :port           => '587',
  :enable_starttls_auto => true,
  :authentication => :login,
  :user_name      => ENV['MAILGUN_USERNAME'],
  :password       => ENV['MAILGUN_SMTP_PASSWORD'],
  :domain         => 'sciolyreg.org'
}
ActionMailer::Base.delivery_method = :smtp
