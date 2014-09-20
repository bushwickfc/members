class MembersController < ApplicationController
  before_action :set_selects, only: [:new, :edit, :create, :update]
  before_action :set_member, only: [:show, :edit, :update, :destroy]
  before_action :set_hashed_member, only: [:optout, :optout_update]
  before_action :build_note, only: [:show, :edit, :update, :destroy]

  # GET /members
  # GET /members.json
  # GET /members.csv
  def index
    if params[:inactive]
      @members = Member.where(status: %w[canceled inactive])
    elsif params[:interested]
      @members = Member.where(status: %w[volunteer interested])
    elsif params[:active_unpaid]
      mems = Member.cached_can_shop.inject([]) do |ary,member|
        ary << member.id unless member.fees.membership_paid?
        ary
      end
      @members = Member.where(id: mems)
    else
      @members = Member.cached_can_shop
    end
    @members = @members.where(valid_search_params).order(:last_name, :first_name)
    @status_totals = Member.status_totals
    respond_with(@members)
  end

  # GET /members/1
  # GET /members/1.json
  # GET /members/1.csv
  def show
    @can_shop = @member.can_shop?
    @messages = @member.can_shop_messages
    @notes = @member.all_notes
    respond_with(@member)
  end

  # GET /members/new
  def new
    @member = Member.new
    build_note
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

  # GET /optout/:sha1_hash
  def optout
  end

  # POST /optout/:sha1_hash
  def optout_update
    @member.opt_out = !@member.opt_out
    if @member.save
      redirect_to :back
    else
      render :optout
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    def set_hashed_member
      @member = Member.by_email_hash(params[:hash])
    end

    def build_note
      @note = Note.new(commentable_id: @member.id, commentable_type: @member.class.to_s, creator_id: current_member.id)
    end

    def set_selects
      @genders  = Member.genders
      @statuses = Member.statuses
      @contact_preferences = Member.contact_preferences
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      pws = %w[password password_confirmation]
      attrs = params.require(:member).permit Member.permitted_params
      attrs.reject! do |k,v| 
        ((!@member.nil? && current_member.id != @member.id) && !current_member.admin?) ||
          pws.include?(k) && v.blank?
      end
      attrs
    end
end
