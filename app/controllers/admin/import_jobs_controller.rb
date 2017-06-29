#
# QGISからのデータインポートジョブを管理する
#
class Admin::ImportJobsController < ApplicationController

  before_action :import_job_not_in_progress, only: %i(create)
  before_action :set_import_job, only: %i(show)


  def index
    @q = ImportJob.ransack(params[:q])
    @import_jobs = @q.result.order(created_at: :desc).page(page).per(per_page)
  end

  def show
  end

  def create
    @result = QgisPhoto.import(user: current_user, force: params[:force].present?)
    redirect_to admin_import_jobs_url
  end

  private

    #
    # 指定したIDのジョブを設定する
    #
    def set_import_job
      @import_job = ImportJob.find_by(id: params[:id])
      if @import_job.blank?
        redirect_to admin_import_jobs_url, notice: t("shared.alert.resource_not_found")
      end
    end


end
