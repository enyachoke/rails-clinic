class Exam < ActiveRecord::Base

  ID_PREFIX = "EX"

  belongs_to :customer, inverse_of: :exams
  belongs_to :examiner, class_name: 'User'

  has_many :qs,             dependent: :destroy, inverse_of: :exam
  has_many :patient_diags,  dependent: :destroy, inverse_of: :exam

  has_many :diags, through: :patient_diags
  accepts_nested_attributes_for :patient_diags, allow_destroy: true, reject_if: :reject_diags

  has_many :patient_drugs,  dependent: :destroy, inverse_of: :exam
  accepts_nested_attributes_for :patient_drugs, allow_destroy: true, reject_if: :reject_drugs 

  has_many :appointments,   dependent: :destroy, inverse_of: :exam
  accepts_nested_attributes_for :appointments, allow_destroy: true, reject_if: :reject_appointments

  validates :weight, :height, :numericality => {:greater_than => 0, :less_than => 500}, 
    format: { with: /\A\d{1,3}(\.\d{1})?\z/ }, allow_blank: true
  validates :pulse, :numericality => {:greater_than => 0, :less_than => 300}, 
    format: { with: /\A\d{1,3}(\.\d{1})?\z/ }, allow_blank: true
  validates :bp_systolic, :bp_diastolic, :numericality => {:greater_than => 0, :less_than => 300}, 
    format: { with: /\A\d{1,3}\z/ }, allow_blank: true

  validates :revenue, numericality: {greater_than_or_equal_to: 0}

  validates :customer, presence: true
  
  #kaminari
  paginates_per 10
  
  class << self
    #scope

    def eager
      includes(customer: [:prefix])
    end

    def eager_for_customer(cid)
      eager.where("customer_id = ?", cid)
    end

    def for_customer(cid)
      # workaround for ransack bug
      # https://github.com/activerecord-hackery/ransack/issues/593
      #cid = 1 if cid == true
      where("customer_id = ?", cid)
    end


    def created_last_24
      current_time = Time.current
      where("exams.created_at between ? and ?", current_time - 24.hours, current_time).eager()
    end
  end

  def reject_drugs(attributes)
    attributes['amount'].blank? or attributes['revenue'].blank?
  end

  def reject_diags(attributes)
    attributes['diag_id'].blank?
  end

  def reject_appointments(attributes)
    attributes['date(1i)'].blank? or
      attributes['date(2i)'].blank? or
      attributes['date(3i)'].blank?
  end

  def bmi
    result = "N/A"
    if weight.present? && height.present?
      result = weight / ((height / 100) ** 2)
      result = result.round(1)
    end
    result
  end

  def paid?
    self.paid_status
  end

  def sum_revenue
    sum = 0.0
    sum += self.revenue if self.revenue

    if self.patient_drugs
      self.patient_drugs.each do |pd|
        sum += pd.revenue if pd.revenue
      end
    end

    sum
  end

  def pay
    self.transaction do
      self.patient_drugs.each do |pd|
        dmm = DrugMovement.new({patient_drug: pd, amount: -pd.amount})
        pd.drug_in.create_movement_for_drug_out(dmm)
        
        pd.drug_in.save!
        pd.drug_in.drug.recal_balance
      end

      self.paid_status = true
      self.save!
    end
  end

end
