class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  respond_to :html, :json, :csv

  private
  def note_params
    [:commentable_id, :commentable_type, :creator_id, :note]
  end

  def valid_search_params
    if params[:search].nil?
      {}
    else
      params[:search].reject{|s,v| v.blank?}
    end
  end
end
