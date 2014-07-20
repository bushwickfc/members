class Members::FurloughsController < ApplicationController
  before_action :set_member

  # GET /members/:member_id/furloughs
  # GET /members/:member_id/furloughs.json
  # GET /members/:member_id/furloughs.csv
  def index
    @furloughs = @member.furloughs.include_parents.where(params[:search])
    respond_with(@furloughs)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:member_id])
    end

end
