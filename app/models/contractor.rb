class Contractor < ApplicationRecord
  has_person_name

  belongs_to :partner_company
  has_many :consultants, dependent: :destroy
  has_many :clients, through: :consultants

  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :for_given_clients, -> (client_ids) { joins(:clients).where('clients.id' => client_ids) }

  def clients_without_employees
    clients - Client.joins(:consultants).where('consultants.employee_id').uniq
  end

  def client_ids
    clients.pluck(:id)
  end
end
