#
# 管理者機能 タグ管理
#
# データインポート中は登録・変更・削除できない
#
class Admin::TagsController < Admin::BaseController

  before_action :import_job_not_in_progress, except: %i(index)
  before_action :set_tag, only: %i(edit update destroy)

  # GET /tags
  # GET /tags.json
  def index
    @q = Tag.ransack(params[:q])
    @tags = @q.result.includes(:archive_tags).order(:name).page(page).per(per_page)
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      redirect_to admin_tags_url, notice: flash_message(:create, model: Tag, target: @tag.name)
    else
      render :new
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_url, notice: flash_message(:update, model: Tag, target: @tag.name)
    else
      render :edit
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    if @tag.destroy
      redirect_to admin_tags_url, notice: flash_message(:destroy, model: Tag, target: @tag.name)
    else
      redirect_to admin_tags_url, notice: t(".failure")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find_by(id: params[:id])
      if @tag.blank?
        redirect_to admin_tags_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.fetch(:tag, {}).permit :name, :enabled
    end

end
