ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.mandrillapp.com',
  :port           => '587',
  :enable_starttls_auto => true,
  :authentication => :login,
  :user_name      => ENV['MANDRILL_USERNAME'],
  :password       => ENV['MANDRILL_APIKEY'],
  :domain         => 'sciolyreg.org'
}
