class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_member!
  protect_from_forgery with: :exception
  respond_to :html, :json, :csv

  def after_sign_in_path_for(resource)
    if resource.admin?
      root_path
    else
      member_path(resource)
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit Member.permitted_params }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :full_name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit Member.permitted_params }
  end

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
