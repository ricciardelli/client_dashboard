class Client < ApplicationRecord
  has_person_name

  has_many :consultants, dependent: :destroy
  has_many :employees, through: :consultants
  has_many :contractors, through: :consultants
  has_many :companies, through: :employees
  has_many :partner_companies, through: :contractors

  validates :ctoken, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  before_validation :generate_token, on: :create

  scope :for_given_employees, -> (employee_ids) { joins(:employees).where('employees.id' => employee_ids) }
  scope :for_given_contractors, -> (contractor_ids) { joins(:contractors).where('contractors.id' => contractor_ids) }
  scope :for_company, -> (company_id) { joins(:companies).where('companies.id' => company_id) }
  scope :for_partner_company, -> (partner_company_id) { joins(:partner_companies).where('partner_companies.id' => partner_company_id) }

  private

  def generate_token
    begin
      self.ctoken = SimpleTokenGenerator::Generator.call(slices: 3, size_of_slice: 2)
    end while self.class.exists?(ctoken: ctoken)
  end
end
