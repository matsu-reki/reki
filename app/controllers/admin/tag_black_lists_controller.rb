#
# 管理者機能 タグ禁止用語管理
#
# データインポート中は登録・変更・削除できない
#
class Admin::TagBlackListsController < Admin::BaseController

  before_action :import_job_not_in_progress, except: %i(index)
  before_action :set_tag_black_list, only: %i(edit update destroy)

  # GET /tag_black_lists
  # GET /tag_black_lists.json
  def index
    @q = TagBlackList.ransack(params[:q])
    @tag_black_lists = @q.result.order(:name).page(page).per(per_page)
  end

  # GET /tag_black_lists/new
  def new
    @tag_black_list = TagBlackList.new
  end

  # GET /tag_black_lists/1/edit
  def edit
  end

  # POST /tag_black_lists
  # POST /tag_black_lists.json
  def create
    @tag_black_list = TagBlackList.new(tag_black_list_params)

    if @tag_black_list.save
      redirect_to admin_tag_black_lists_url,
        notice: flash_message(:create, model: TagBlackList, target: @tag_black_list.name)
    else
      render :new
    end
  end

  # PATCH/PUT /tag_black_lists/1
  # PATCH/PUT /tag_black_lists/1.json
  def update
    if @tag_black_list.update(tag_black_list_params)
      redirect_to admin_tag_black_lists_url,
        notice: flash_message(:update, model: TagBlackList, target: @tag_black_list.name)
    else
      render :edit
    end
  end

  # DELETE /tag_black_lists/1
  # DELETE /tag_black_lists/1.json
  def destroy
    if @tag_black_list.destroy
      redirect_to admin_tag_black_lists_url,
        notice: flash_message(:destroy, model: TagBlackList, target: @tag_black_list.name)
    else
      redirect_to admin_tag_black_lists_url, notice: t(".failure")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag_black_list
      @tag_black_list = TagBlackList.find_by(id: params[:id])
      if @tag_black_list.blank?
        redirect_to admin_tag_black_lists_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_black_list_params
      params.fetch(:tag_black_list, {}).permit :name, :enabled
    end

end
