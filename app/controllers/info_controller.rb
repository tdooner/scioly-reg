class InfoController < ApplicationController
  before_filter :is_admin, :only => :edit
  def index
    @info = Info.find(:all)
    breadcrumbs.add("Event Information")
  end
  def show
    @info = Info.find(params[:id])
    breadcrumbs.add("Event Information", info_index_url)
    breadcrumbs.add(@info.human_name)
  end
  def edit
    @info = Info.find(params[:id])
    breadcrumbs.add("Edit " + @info.human_name)
  end
  def update
    @info = Info.find(params[:id])
    if @info.update_attributes(params[:info])
      redirect_to info_url(params[:id])
    else
      flash[:error] = @info.errors.full_messages.first
      redirect_to edit_info_url(params[:id])
    end
  end
end
