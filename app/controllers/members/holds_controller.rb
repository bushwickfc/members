class Members::HoldsController < ApplicationController
  before_action :set_member
  before_action :set_hold, only: [:show, :edit, :update, :destroy]
  before_action :set_selects, only: [:new, :edit, :create, :update]
  before_action :build_note, only: [:show, :edit, :update, :destroy]

  # GET /members/:member_id/holds
  # GET /members/:member_id/holds.json
  # GET /members/:member_id/holds.csv
  def index
    @holds = @member.holds.include_parents.where(params[:search])
    @creator = Member.new
    respond_with(@holds)
  end

  # GET /members/:member_id/holds/1
  # GET /members/:member_id/holds/1.json
  # GET /members/:member_id/holds/1.csv
  def show
    @notes = @hold.notes
    respond_with(@hold)
  end

  # GET /members/:member_id/holds/new
  def new
    @creator = Member.new
    @hold = @member.holds.new
    build_note
  end

  # GET /members/:member_id/holds/1/edit
  def edit
  end

  # POST /members/:member_id/holds
  # POST /members/:member_id/holds.json
  def create
    @hold = @member.holds.new(hold_params)

    respond_to do |format|
      if @hold.save
        format.html { redirect_to member_hold_path(@member, @hold), notice: 'Hold was successfully created.' }
        format.json { render :show, status: :created, location: @hold }
      else
        format.html { render :new }
        format.json { render json: @hold.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/:member_id/holds/1
  # PATCH/PUT /members/:member_id/holds/1.json
  def update
    respond_to do |format|
      if @hold.update(hold_params)
        format.html { redirect_to member_hold_path(@member, @hold), notice: 'Hold was successfully updated.' }
        format.json { render :show, status: :ok, location: @hold }
      else
        format.html { render :edit }
        format.json { render json: @hold.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/:member_id/holds/1
  # DELETE /members/:member_id/holds/1.json
  def destroy
    @hold.destroy
    respond_to do |format|
      format.html { redirect_to member_furloughs_url(@member), notice: 'Hold was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:member_id])
    end

    def set_hold
      @hold = Hold.include_parents.find(params[:id])
      @creator = @hold.creator
    end

    def build_note
      @note = Note.new(commentable_id: @hold.id, commentable_type: @hold.class.to_s, creator_id: current_member.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hold_params
      params.require(:hold).permit(
        :member_id,
        :creator_id,
        :type,
        :start,
        :finish,
        notes_attributes: note_params
      )
    end

    def set_selects
    end
end
