class TournamentsController < ApplicationController
  before_filter :is_admin

  def create
  end

  def new
  end

  def edit
	  @tournament = Tournament.find(params[:id])
	  breadcrumbs.add("Edit Tournament #" + @tournament.id.to_s)
  end

  def index
	  @tournaments = Tournament.find(:all)
	  breadcrumbs.add("Edit Tournaments")
  end

  def show
	  @tournament = Tournament.find(params[:id])
	  breadcrumbs.add(@tournament.humanize() + " Tournament")
  end

  def update
	  @t = Tournament.find(params[:id])
	  @t.update_attributes(params[:tournament])
	  redirect_to :tournaments
  end

  def destroy
  end

end
