class AdminController < ApplicationController
  def index
	  breadcrumbs.add("Admin")
  end
end
