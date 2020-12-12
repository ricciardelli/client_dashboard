class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  # GET /employees
  # GET /employees.json
  def index
    if params[:company_id].present?
      @employees = Employee.where(company_id: params[:company_id]).all
    else
      @employees = Employee.all
    end
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
  end

  def new_upload
    respond_to do |format|
      format.html
      format.js
    end
  end

  def upload
    file = params[:file]

    begin
      data = read_file file
      store_employee_data data
      flash[:notice] = 'Employee data has been uploaded successfully.'
      render json: flash
    rescue Employee::EmployeeError => error
      render json: { error: error.message }, status: error.status and return
    rescue ActiveRecord::RecordInvalid
      render json: { error: 'Cannot save information on the database, invalid data' }, status: :bad_request and return
    rescue => error
      logger.error error.message
      render json: { error: 'Unknown error' }, status: :internal_server_error and return
    end
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employees/1
  # PATCH/PUT /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_url, notice: 'Employee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params
    params.require(:employee).permit(:identifier, :first_name, :last_name, :company_id)
  end

  # Reads a file and returns a Roo::Spreadsheet object that can be manipulated by the application
  def read_file(file)
    spreadsheet = Roo::Spreadsheet.open file
    raise Employee::InvalidFileError if spreadsheet.first_row.nil?
    raise Employee::NoHeadersError unless spreadsheet.row(1).any? && headers_present?(spreadsheet)
    raise Employee::NoContentError unless spreadsheet.row(2).any?
    spreadsheet
  end

  # Stores the given employee data into the database
  def store_employee_data(employees)
    headers = Hash[employees.row(1).collect { |e| [e, e] }]
    Employee.transaction do
      employees.parse(headers).each do |employee|
        employee['consultant_ids'] = employee['consultant_ids'].split(',') if employee['consultant_ids'].is_a? String
        Employee.create! employee
      end
    end
  end

  def headers_present?(spreadsheet)
    Employee::REQUIRED_FIELDS.sort == spreadsheet.row(1).map(&:to_s).map(&:to_sym).sort
  end
end
