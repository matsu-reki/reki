#
# 管理者機能 ユーザ管理
#
# データインポート中は登録・変更・削除できない
#
class Admin::UsersController < Admin::BaseController

  before_action :import_job_not_in_progress, except: %i(index)
  before_action :set_user, only: %i(show edit update destroy)

  # GET /users
  # GET /users.json
  def index
    @q = User.ransack(params[:q])
    @users = @q.result.order(:login).page(page).per(per_page)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_url, notice: flash_message(:create, model: User, target: @user.name)
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: flash_message(:update, model: User, target: @user.name)
    else
      render :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if @user.destroyable?(current_user)
      @user.destroy
      redirect_to admin_users_url, notice: flash_message(:destroy, model: User, target: @user.name)
    else
      redirect_to admin_users_url, notice: t(".failure")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(id: params[:id])
      if @user.blank?
        redirect_to admin_users_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {}).permit(
        :email, :enabled, :login, :name, :role, :password, :password_confirmation
      )
    end
end
