class DrugMovementsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_drug_movement, only: [:show, :destroy]
  #before_action :set_ransack_search_param, only: [:index]
  before_action :set_drug_in, only: [:index, :new, :create]
  before_action :set_drug_in_from_drug_movement, only: [:show]
  before_action :set_drug_from_drug_in, only: [:show, :new]

  def index
    ransack_params = {for_drug_in: @drug_in.id}
    ransack_params = ransack_params.merge(params[:q]) if params[:q]

    @q = DrugMovement.ransack(ransack_params)
    @drug_movements = @q.result.page(params[:page])

    @drug = @drug_in.drug
  end

  def show
  end

  def new
    @drug_movement = DrugMovement.new
  end

  def edit
  end

  def create
    @drug_movement = DrugMovement.new(drug_movement_params)
    @drug_in.create_movement_for_drug_out(@drug_movement)

    if @drug_in.save
      @drug_in.drug.recal_balance
      redirect_to drug_in_drug_movements_url(@drug_in), notice: t("successfully_created")
    else
      render :new
    end
#    drug_in.transaction do
#      @drug_in.save
#      @drug_in.drug.recal_balance
#    end
  end

  private
    #def set_ransack_search_param
    #  @q = DrugMovement.ransack(params[:q])
    #end

    def set_drug_in
      @drug_in = DrugIn.find(params[:drug_in_id])
    end

    def set_drug_in_from_drug_movement
      @drug_in = @drug_movement.drug_in
    end

    def set_drug_from_drug_in
      @drug = @drug_in.drug
    end

    def drug_movement_params
      params.require(:drug_movement).permit(:note, :amount)
    end

    def set_drug_movement
      @drug_movement = DrugMovement.find(params[:id])
    end

#    def set_drugs
#      @drugs = Drug.drug_ins_exist
#    end

    def set_exam
      @exam = @drug_movement.exam
    end

end