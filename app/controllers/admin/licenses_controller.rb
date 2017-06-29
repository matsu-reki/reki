#
# 管理者機能 ライセンス管理
#
# データインポート中は登録・変更・削除できない
#
class Admin::LicensesController < Admin::BaseController

  before_action :import_job_not_in_progress, except: %i(index)
  before_action :set_license, only: %i(show edit update destroy)

  # GET /licenses
  # GET /licenses.json
  def index
    @q = License.ransack(params[:q])
    @licenses = @q.result.order(:code).page(page).per(per_page)
  end

  # GET /licenses/new
  def new
    @license = License.new
  end

  # GET /licenses/1
  def show
    render "show", layout: "docs"
  end

  # GET /licenses/1/edit
  def edit
  end

  # POST /licenses
  # POST /licenses.json
  def create
    @license = License.new(license_params)

    if @license.save
      redirect_to admin_licenses_url, notice: flash_message(:create, model: License, target: @license.name)
    else
      render :new
    end
  end

  # PATCH/PUT /licenses/1
  # PATCH/PUT /licenses/1.json
  def update
    if @license.update(license_params)
      redirect_to admin_licenses_url, notice: flash_message(:update, model: License, target: @license.name)
    else
      render :edit
    end
  end

  # DELETE /licenses/1
  # DELETE /licenses/1.json
  def destroy
    if @license.destroy
      redirect_to admin_licenses_url, notice: flash_message(:destroy, model: License, target: @license.name)
    else
      redirect_to admin_licenses_url, notice: t(".failure")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_license
      @license = License.find_by(id: params[:id])
      if @license.blank?
        redirect_to admin_licenses_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def license_params
      params.fetch(:license, {}).permit :code, :content, :content_type, :name, :enabled
    end
end
