class FeesController < ApplicationController
  before_action :set_fee, only: [:show, :edit, :update, :destroy]
  before_action :set_selects, only: [:new, :edit, :create, :update]
  before_action :build_note, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /fees
  # GET /fees.json
  # GET /fees.csv
  def index
    @fees = Fee.include_parents.where(params[:search])
    respond_with(@fees)
  end

  # GET /fees/1
  # GET /fees/1.csv
  def show
    respond_with(@fee)
  end

  # GET /fees/new
  def new
    @fee = Fee.new(creator_id: current_member.id)
    build_note
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
        format.html { build_note; render :new }
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
      @fee = Fee.include_parents.find(params[:id])
    end

    def build_note
      @note = Note.new(commentable_id: @fee.id, commentable_type: @fee.class.to_s, creator_id: current_member.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fee_params
      params.require(:fee).permit(
        :member_id,
        :creator_id,
        :amount,
        :payment_date,
        :payment_type,
        :payment_method,
        notes_attributes: note_params
      )
    end

    def set_selects
      @members = Member.form_select.collect{|r| [r.full_name, r.id]}
      @creators = Member.form_select.collect{|r| [r.full_name, r.id]}
      @payment_types = Fee.payment_types
      @payment_methods = Fee.payment_methods
    end
end
