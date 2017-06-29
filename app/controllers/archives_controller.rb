#
# 資料管理
#
# データインポート中は登録・変更・削除できない
#
class ArchivesController < ApplicationController

  before_action :import_job_not_in_progress, except: %i(index)
  before_action :admin_required, only: %i(destroy update_enabled)
  before_action :set_archive, only: %i(show edit update destroy edit_image update_image)

  # GET /archives
  # GET /archives.json
  def index
    @q = Archive.ransack(params[:q])
    @archives = @q.result.includes(:category, :tags).
      order(Archive.arel_table[:updated_at].desc).
      page(page).per(per_page)
  end

  # GET /archives/1
  # GET /archives/1.json
  def show
  end

  # GET /archives/new
  def new
    @archive = Archive.new
    @archive.prepare_instance_attributes
  end

  # GET /archives/1/edit
  def edit
    @archive.prepare_instance_attributes
  end

  # POST /archives
  # POST /archives.json
  def create
    @archive = current_user.archives.build(archive_params)
    if @archive.save
      redirect_to archives_url, notice: flash_message(:create, model: Archive, target: @archive.name)
    else
      @archive.prepare_instance_attributes
      render :new
    end
  end

  # PATCH/PUT /archives/1
  # PATCH/PUT /archives/1.json
  def update
    if @archive.update(archive_params.merge(updated_user_id: current_user.id))
      redirect_to archives_url, notice: flash_message(:update, model: Archive, target: @archive.name)
    else
      @archive.prepare_instance_attributes
      render :edit
    end
  end

  # DELETE /archives/1
  # DELETE /archives/1.json
  def destroy
    if @archive.destroy
      redirect_to archives_url, notice: flash_message(:destroy, model: Archive, target: @archive.name)
    else
      redirect_to archives_url, notice: t(".failure")
    end
  end

  # サムネイル画像変更画面
  def edit_image
  end

  # サムネイル画像更新
  def update_image
    if @archive.update(archive_update_image_params.merge(updated_user_id: current_user.id))
      redirect_to  archive_archive_assets_url(@archive),
        notice: flash_message(:update, model: Archive, target: @archive.name)
    else
      render :edit
    end
  end

  #
  # 資料の説明からタグを作成する
  #
  def extract_tag
    @tag_labels = Tag.generate(params[:keyword])
  end

  #
  # 公開フラグの一括更新
  #
  def update_enabled
    archives = Archive.where(id: params[:ids])
    if archives.exists?
      if params.has_key?(:enable)
        archives.update_all enabled: true
      elsif params.has_key?(:disable)
        archives.update_all enabled: false
      end
    end
    redirect_to archives_url(q: params[:q], page: params[:page])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive
      @archive = Archive.find_by(id: params[:id])
      if @archive.blank?
        redirect_to archives_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_params
      params.fetch(:archive, {}).permit [
        :author,
        :category_id,
        :created_begin_on,
        :created_end_on,
        :description,
        :enabled,
        :latitude,
        :license_id,
        :location,
        :longitude,
        :map_file,
        :name,
        :note,
        :owner,
        :represent_image,
        :tag_labels,
        { images: [] }
      ]
    end

    def archive_update_image_params
      params.fetch(:archive, {}).permit :represent_image
    end
end
