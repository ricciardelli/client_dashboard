class Consultant < ApplicationRecord
  belongs_to :client
  belongs_to :contractor, optional: true
  belongs_to :employee, optional: true

  def full_name
    if contractor.present?
      contractor.name.full
    else
      employee.name.full
    end
  end

  def company_name
    if contractor.present?
      contractor.partner_company.name
    else
      employee.company.name
    end
  end
end
