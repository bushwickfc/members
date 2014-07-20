class TimeBanksController < ApplicationController
  before_action :set_selects, only: [:new, :edit, :create, :update]
  before_action :set_time_bank, only: [:show, :edit, :update, :destroy]

  # GET /time_banks
  # GET /time_banks.json
  # GET /time_banks.csv
  def index
    @time_banks = TimeBank.select_all.
      where('start >= ?', Date.current-12.months).
      include_parents.
      where(params[:search])
    respond_with(@time_banks)
  end

  # GET /time_banks/1
  # GET /time_banks/1.json
  def show
    respond_with(@time_bank)
  end

  # GET /time_banks/new
  def new
    @time_bank = TimeBank.new
  end

  # GET /time_banks/1/edit
  def edit
  end

  # POST /time_banks
  # POST /time_banks.json
  def create
    @time_bank = TimeBank.new(time_bank_params)

    respond_to do |format|
      if @time_bank.save
        format.html { redirect_to @time_bank, notice: 'TimeBank was successfully created.' }
        format.json { render :show, status: :created, location: @time_bank }
      else
        format.html { render :new }
        format.json { render json: @time_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /time_banks/1
  # PATCH/PUT /time_banks/1.json
  def update
    respond_to do |format|
      if @time_bank.update(time_bank_params)
        format.html { redirect_to @time_bank, notice: 'TimeBank was successfully updated.' }
        format.json { render :show, status: :ok, location: @time_bank }
      else
        format.html { render :edit }
        format.json { render json: @time_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_banks/1
  # DELETE /time_banks/1.json
  def destroy
    @time_bank.destroy
    respond_to do |format|
      format.html { redirect_to time_banks_url, notice: 'TimeBank was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_bank
      @time_bank = TimeBank.select_all.include_parents.find(params[:id])
    end

    def set_selects
      @members = Member.form_select.collect{|m| [m.full_name, m.id]}
      @admins = Admin.form_select.collect{|m| [m.full_name, m.id]}
      @committees = Committee.form_select.collect{|m| [m.name, m.id]}
      @time_types = TimeBank.time_types
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_bank_params
      params.require(:time_bank).permit(:member_id, :admin_id, :committee_id, :start, :finish, :time_type, :approved)
    end
end
