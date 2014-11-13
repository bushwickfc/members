class Members::FurloughsController < ApplicationController
  load_and_authorize_resource :member
  load_and_authorize_resource :furlough, through: :member

  # GET /members/:member_id/furloughs
  # GET /members/:member_id/furloughs.json
  # GET /members/:member_id/furloughs.csv
  def index
    @furloughs = @member.furloughs.include_parents.where(params[:search])
    respond_with(@furloughs)
  end

end
