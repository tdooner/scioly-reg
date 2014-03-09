class HomeController < ApplicationController
  before_filter :redirect_to_app_if_subdomain, :except => :index

  layout 'no_school'

  def index
    @schools = School.all
  end

  def logged_in
  end

  def about
  end

private

  def redirect_to_app_if_subdomain
    # Redirect from http://cwru.sciolyreg.org/about to
    # http://sciolyreg.org/about.
    #
    # Also, the port stuff is here for local development.
    host = (request.port == 80) ? "#{request.domain}" :
      "#{request.domain}:#{request.port}"
    redirect_to url_for(:action => action_name, :host => host) if @current_school
  end
end
