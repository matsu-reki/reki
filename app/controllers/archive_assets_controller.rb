#
# 資料画像管理
#
# データインポート中は登録・変更・削除できない
#
class ArchiveAssetsController < ApplicationController

  before_action :import_job_not_in_progress, except: %i(index)
  before_action :set_archive
  before_action :set_archive_asset, only: %i(edit update destroy)
  before_action :validate_assets_count, only: %i(new create)

  def index
    @archive_assets = @archive.archive_assets.order("archive_assets.id ASC")
  end

  # GET /archive_assets/new
  def new
    @archive_asset = ArchiveAsset.new
  end

  # GET /archive_assets/1/edit
  def edit
  end

  # POST /archive_assets
  # POST /archive_assets.json
  def create
    @archive_asset = @archive.archive_assets.build(archive_asset_params)
    if @archive_asset.save
      redirect_to archive_archive_assets_url(@archive),
        notice: flash_message(:create, model: ArchiveAsset)
    else
      render :new
    end
  end

  # PATCH/PUT /archive_assets/1
  # PATCH/PUT /archive_assets/1.json
  def update
    if @archive_asset.update(archive_asset_params)
      redirect_to archive_archive_assets_url(@archive),
        notice: flash_message(:update, model: ArchiveAsset)
    else
      render :edit
    end
  end

  # DELETE /archive_assets/1
  # DELETE /archive_assets/1.json
  def destroy
    if @archive_asset.destroy
      redirect_to archive_archive_assets_url(@archive),
        notice: flash_message(:destroy, model: ArchiveAsset)
    else
      redirect_to archive_archive_assets_url(@archive), notice: t(".failure")
    end
  end

  private

    def set_archive
      @archive = Archive.find_by(id: params[:archive_id])
      if @archive.blank?
        redirect_to archives_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_archive_asset
      @archive_asset = ArchiveAsset.find_by(id: params[:id])
      if @archive_asset.blank?
        redirect_to archive_archive_assets_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_asset_params
      params.fetch(:archive_asset, {}).permit :image
    end

    # 画像ファイル数が上限に達した場合、一覧画面に戻す
    def validate_assets_count
      if @archive.assets_limit?
        redirect_to archive_archive_assets_url(@archive),
          alert: t("archive_assets.limit", limit: Settings.archive.assets.maximum)
        return
      end
    end
end
