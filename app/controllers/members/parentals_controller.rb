class Members::ParentalsController < ApplicationController
  load_and_authorize_resource :member
  load_and_authorize_resource :parental, through: :member
  before_action :set_parental, only: [:show, :edit, :update, :destroy]
  before_action :set_selects, only: [:new, :edit, :create, :update]
  before_action :build_note, only: [:show, :edit, :update, :destroy]

  # GET /members/:member_id/parentals
  # GET /members/:member_id/parentals.json
  # GET /members/:member_id/parentals.csv
  def index
    @parentals = @member.parentals.include_parents.where(params[:search])
    respond_with(@parentals)
  end

  # GET /members/:member_id/parentals/1
  # GET /members/:member_id/parentals/1.json
  # GET /members/:member_id/parentals/1.csv
  def show
    @notes = @parental.notes
    respond_with(@parental)
  end

  # GET /members/:member_id/parentals/new
  def new
    @parental = @member.parentals.new(creator_id: current_member.id)
    build_note
  end

  # GET /members/:member_id/parentals/1/edit
  def edit
  end

  # POST /members/:member_id/parentals
  # POST /members/:member_id/parentals.json
  def create
    @parental = @member.parentals.new(parental_params)

    respond_to do |format|
      if @parental.valid? && @parental.save
        format.html { redirect_to member_parental_path(@member, @parental), notice: 'Parental Leave was successfully created.' }
        format.json { render :show, status: :created, location: @parental }
      else
        format.html { build_note; render :new }
        format.json { render json: @parental.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/:member_id/parentals/1
  # PATCH/PUT /members/:member_id/parentals/1.json
  def update
    respond_to do |format|
      if @parental.update(parental_params)
        format.html { redirect_to member_parental_path(@member, @parental), notice: 'Parental Leave was successfully updated.' }
        format.json { render :show, status: :ok, location: @parental }
      else
        format.html { render :edit }
        format.json { render json: @parental.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/:member_id/parentals/1
  # DELETE /members/:member_id/parentals/1.json
  def destroy
    @parental.destroy
    respond_to do |format|
      format.html { redirect_to member_furloughs_url(@member), notice: 'Parental Leave was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parental
      @parental = Parental.include_parents.find(params[:id])
    end

    def build_note
      @note = Note.new(commentable_id: @parental.id, commentable_type: @parental.class.to_s, creator_id: current_member.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def parental_params
      params.require(:parental).permit(
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
