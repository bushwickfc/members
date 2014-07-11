class FeesController < ApplicationController
  before_action :set_fee, only: [:show, :edit, :update, :destroy]
  before_action :set_selects, only: [:new, :edit]

  # GET /fees
  # GET /fees.json
  # GET /fees.csv
  def index
    @fees = Fee.where(params[:search])
    @receiver = Receiver.new
    respond_with(@fees)
  end

  # GET /fees/1
  # GET /fees/1.csv
  def show
    respond_with(@fee)
  end

  # GET /fees/new
  def new
    @receiver = Receiver.new
    @fee = Fee.new
  end

  # GET /fees/1/edit
  def edit
  end

  # POST /fees
  # POST /fees.json
  def create
    @fee = Fee.new(fee_params)

    respond_to do |format|
      if @fee.save
        format.html { redirect_to fee_path(@fee), notice: 'Fee was successfully created.' }
        format.json { render :show, status: :created, location: @fee }
      else
        format.html { render :new }
        format.json { render json: @fee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fees/1
  # PATCH/PUT /fees/1.json
  def update
    respond_to do |format|
      if @fee.update(fee_params)
        format.html { redirect_to fee_path(@fee), notice: 'Fee was successfully updated.' }
        format.json { render :show, status: :ok, location: @fee }
      else
        format.html { render :edit }
        format.json { render json: @fee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fees/1
  # DELETE /fees/1.json
  def destroy
    @fee.destroy
    respond_to do |format|
      format.html { redirect_to fees_url, notice: 'Fee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fee
      @fee = Fee.find(params[:id])
      @receiver = @fee.receiver
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fee_params
      params.require(:fee).permit(:member_id, :receiver_id, :amount, :payment_date, :payment_type, :payment_method)
    end

    def set_selects
      @members = Member.form_select.collect{|r| [r.full_name, r.id]}
      @receivers = Receiver.form_select.collect{|r| [r.full_name, r.id]}
      @payment_types = Fee.payment_types
      @payment_methods = Fee.payment_methods
    end
end
