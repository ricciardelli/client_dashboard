class Employee < ApplicationRecord
  has_person_name

  belongs_to :company
  has_many :consultants, dependent: :destroy
  has_many :clients, through: :consultants

  validates :identifier, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  before_validation :generate_token, on: :create

  scope :for_given_clients, -> (client_ids) { joins(:clients).where('clients.id' => client_ids) }

  REQUIRED_FIELDS = [:first_name, :last_name, :company_id, :consultant_ids]

  def client_ids
    clients.pluck(:id)
  end

  private

  def generate_token
    begin
      self.identifier = SimpleTokenGenerator::Generator.call(slices: 3, size_of_slice: 2)
    end while self.class.exists?(identifier: identifier)
  end

  class EmployeeError < StandardError
    include Singleton

    def status
      :bad_request
    end
  end

  class NoContentError < EmployeeError
    def message
      'The file does not contain any row data besides the header, please submit data'
    end
  end

  class NoHeadersError < EmployeeError
    def message
      "The file must contain the required headers: #{REQUIRED_FIELDS}"
    end
  end

  class InvalidFileError < EmployeeError
    def message
      'The file is invalid'
    end
  end

end
