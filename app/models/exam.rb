class Exam < ActiveRecord::Base

  ID_PREFIX = "EX"

  belongs_to :customer, inverse_of: :exams
  belongs_to :examiner, class_name: 'User'

  has_many :patient_diags
  has_many :diags, through: :patient_diags
  accepts_nested_attributes_for :patient_diags, allow_destroy: true, reject_if: :all_blank

  has_many :patient_drugs, inverse_of: :exam
  accepts_nested_attributes_for :patient_drugs, allow_destroy: true, reject_if: :all_blank

  has_many :drug_movements, inverse_of: :exam

  validates :weight, :height, :numericality => {:greater_than => 0, :less_than => 500}, 
    format: { with: /\A\d{1,3}(\.\d{1})?\z/ }, allow_blank: true
  validates :pulse, :numericality => {:greater_than => 0, :less_than => 300}, 
    format: { with: /\A\d{1,3}(\.\d{1})?\z/ }, allow_blank: true
  validates :bp_systolic, :bp_diastolic, :numericality => {:greater_than => 0, :less_than => 300}, 
    format: { with: /\A\d{1,3}\z/ }, allow_blank: true

  validates :customer, presence: true
  
  #kaminari
  paginates_per 10
  
  class << self
    #scope
    def for_customer(cid)
      # workaround for ransack bug
      # https://github.com/activerecord-hackery/ransack/issues/593
      cid = 1 if cid == true

      where("customer_id = ?", cid)
    end

    def ransackable_scopes(auth_object = nil)
      %i(for_customer)
    end
  end

  def bmi
    result = "N/A"
    if weight.present? && height.present?
      result = weight / ((height / 100) ** 2)
      result = result.round(1)
    end
    result
  end
  
end
