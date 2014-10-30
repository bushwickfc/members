class Committees::TimeBanksController < ApplicationController
  before_action :set_committee
  before_action :set_selects, only: [:new, :edit, :create, :update]
  before_action :set_time_bank, only: [:show, :edit, :update, :destroy]
  before_action :build_note, only: [:show, :edit, :update, :destroy]

  # GET /committees/:comittee_id/time_banks
  # GET /committees/:comittee_id/time_banks.json
  # GET /committees/:comittee_id/time_banks.csv
  def index
    @time_banks = @committee.time_banks.select_all.include_parents.where(params[:search])
    respond_with(@time_banks)
  end

  # GET /committees/:comittee_id/time_banks/1
  # GET /committees/:comittee_id/time_banks/1.json
  def show
    respond_with(@time_bank)
  end

  # GET /committees/:committee_id/time_banks/new
  def new
    @time_bank = @committee.time_banks.new
    build_note
  end

  # GET /committees/:committee_id/time_banks/1/edit
  def edit
  end

  # POST /committees/:committee_id/time_banks
  # POST /committees/:committee_id/time_banks.json
  def create
    @time_bank = @committee.time_banks.new(time_bank_params)

    respond_to do |format|
      if @time_bank.save
        format.html { redirect_to committee_time_bank_path(@committee, @time_bank), notice: 'TimeBank was successfully created.' }
        format.json { render :show, status: :created, location: @time_bank }
      else
        format.html { build_note; render :new }
        format.json { render json: @time_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /committees/:committee_id/time_banks/1
  # PATCH/PUT /committees/:committee_id/time_banks/1.json
  def update
    respond_to do |format|
      if @time_bank.update(time_bank_params)
        format.html { redirect_to committee_time_bank_path(@committee, @time_bank), notice: 'TimeBank was successfully updated.' }
        format.json { render :show, status: :ok, location: @time_bank }
      else
        format.html { render :edit }
        format.json { render json: @time_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /committees/:committee_id/time_banks/1
  # DELETE /committees/:committee_id/time_banks/1.json
  def destroy
    @time_bank.destroy
    respond_to do |format|
      format.html { redirect_to committee_time_banks_url, notice: 'TimeBank was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_committee
      @committee = Committee.find(params[:committee_id])
    end

    def set_time_bank
      @time_bank = @committee.time_banks.select_all.include_parents.find(params[:id])
    end

    def set_selects
      @members = Member.form_select.collect{|m| [m.full_name, m.id]}
      @admins = Admin.form_select.collect{|m| [m.full_name, m.id]}
      @time_types = TimeBank.time_types
    end

    def build_note
      @note = Note.new(commentable_id: @time_bank.id, commentable_type: @time_bank.class.to_s, creator_id: current_member.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_bank_params
      params.require(:time_bank).permit(
        :member_id,
        :admin_id,
        :committee_id,
        :start,
        :finish,
        :time_type,
        :approved,
        notes_attributes: note_params
      )
    end
end
