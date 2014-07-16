class MembersController < ApplicationController
  before_action :set_selects, only: [:new, :edit]
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  # GET /members
  # GET /members.json
  # GET /members.csv
  def index
    @members = Member.where(params[:search])
    respond_with(@members)
  end

  # GET /members/1
  # GET /members/1.json
  # GET /members/1.csv
  def show
    respond_with(@member)
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    def set_selects
      @genders  = Member.genders
      @statuses = Member.statuses
      @contact_preferences = Member.contact_preferences
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(
        :first_name,
        :middle_name, 
        :last_name, 
        :opt_out, 
        :email, 
        :phone, 
        :phone2, 
        :fax, 
        :address, 
        :address2, 
        :city, 
        :state, 
        :country, 
        :zip, 
        :contact_preference,
        :gender, 
        :status, 
        :join_date, 
        :date_of_birth, 
        :on_hold_until, 
        :admin, 
        :membership_agreement, 
        :monthly_hours, 
        :membership_discount, 
        :investment_discount
      )
    end
end
