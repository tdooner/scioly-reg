# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Scioly::Application.initialize!

ENV['RECAPTCHA_PUBLIC_KEY'] = '6LeXWsASAAAAAJFC3UNhubePiGmxvc7L6Cx5TBLI'
ENV['RECAPTCHA_PRIVATE_KEY']= '6LeXWsASAAAAACw8YYyJOiGDFA-0nYstQ37fks87'

require 'casclient'
require 'casclient/frameworks/rails/filter'
CASClient::Frameworks::Rails::Filter.configure(
	      :cas_base_url => "https://login.case.edu/cas/"
)
