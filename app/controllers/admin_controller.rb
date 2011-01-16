class AdminController < ApplicationController
	before_filter :is_admin

  def index
	  breadcrumbs.add("Admin Panel")
  end
end
