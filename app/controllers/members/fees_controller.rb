class Members::FeesController < ApplicationController
  before_action :set_member
  before_action :set_fee, only: [:show, :edit, :update, :destroy]
  before_action :set_selects, only: [:new, :edit, :create, :update]

  # GET /members/:member_id/fees
  # GET /members/:member_id/fees.json
  # GET /members/:member_id/fees.csv
  def index
    @fees = @member.fees.include_parents.where(params[:search])
    @creator = Member.new
    respond_with(@fees)
  end

  # GET /members/:member_id/fees/1
  # GET /members/:member_id/fees/1.json
  # GET /members/:member_id/fees/1.csv
  def show
    respond_with(@fee)
  end

  # GET /members/:member_id/fees/new
  def new
    @creator = Member.new
    @fee = @member.fees.new
  end

  # GET /members/:member_id/fees/1/edit
  def edit
  end

  # POST /members/:member_id/fees
  # POST /members/:member_id/fees.json
  def create
    @fee = @member.fees.new(fee_params)

    respond_to do |format|
      if @fee.save
        format.html { redirect_to member_fee_path(@member, @fee), notice: 'Fee was successfully created.' }
        format.json { render :show, status: :created, location: @fee }
      else
        format.html { render :new }
        format.json { render json: @fee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/:member_id/fees/1
  # PATCH/PUT /members/:member_id/fees/1.json
  def update
    respond_to do |format|
      if @fee.update(fee_params)
        format.html { redirect_to member_fee_path(@member, @fee), notice: 'Fee was successfully updated.' }
        format.json { render :show, status: :ok, location: @fee }
      else
        format.html { render :edit }
        format.json { render json: @fee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/:member_id/fees/1
  # DELETE /members/:member_id/fees/1.json
  def destroy
    @fee.destroy
    respond_to do |format|
      format.html { redirect_to member_fees_url(@member), notice: 'Fee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:member_id])
    end

    def set_fee
      @fee = Fee.include_parents.find(params[:id])
      @creator = @fee.creator
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fee_params
      params.require(:fee).permit(:member_id, :creator_id, :amount, :payment_date, :payment_type, :payment_method)
    end

    def set_selects
      @creators = Member.form_select.collect{|r| [r.full_name, r.id]}
      @payment_types = Fee.payment_types
      @payment_methods = Fee.payment_methods
    end
end
