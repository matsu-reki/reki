#
# 管理者機能 分類管理
#
# データインポート中は登録・変更・削除できない
#
class Admin::CategoriesController < Admin::BaseController

  before_action :import_job_not_in_progress, except: %i(index)
  before_action :set_category, only: %i(edit update destroy)

  # GET /categories
  # GET /categories.json
  def index
    @q = Category.ransack(params[:q])
    @categories = @q.result.order(:code).page(page).per(per_page)
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_url, notice: flash_message(:create, model: Category, target: @category.name)
    else
      render :new
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    if @category.update(category_params)
      redirect_to admin_categories_url, notice: flash_message(:update, model: Category, target: @category.name)
    else
      render :edit
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    if @category.destroy
      redirect_to admin_categories_url, notice: flash_message(:destroy, model: Category, target: @category.name)
    else
      redirect_to admin_categories_url, notice: t(".failure")
    end
  end

  private

    # id から分類を探す
    def set_category
      @category = Category.find_by(id: params[:id])
      if @category.blank?
        redirect_to admin_categories_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # 登録・更新時のパラメータ
    def category_params
      params.fetch(:category, {}).permit(:code, :enabled, :name)
    end

end
