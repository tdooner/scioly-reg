class HomeController < ApplicationController
  before_filter :render_app_if_subdomain, :only => :index
  before_filter :redirect_to_app_if_subdomain, :except => :index

  def index
    render :index, :layout => 'static_page'
  end

  def about
    render :about, :layout => 'static_page'
  end

  private

  def render_app_if_subdomain
    if @current_school
      if not @team.nil? # If logged in...
        breadcrumbs.add("Welcome!")
        render :signup # Render app/views/home/signup.html.haml
      else
        render :login  # app/views/home/login.html.haml
      end
    end
  end

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
