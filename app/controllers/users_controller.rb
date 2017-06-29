#
# ユーザ管理
#
class UsersController < ApplicationController

  before_action :set_user, only: %i(edit update)

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      redirect_to root_url, notice: flash_message(:update, model: User, target: @user.name)
    else
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(id: params[:id])
      if @user.blank?
        redirect_to root_url, notice: t("shared.alert.resource_not_found")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {}).permit(
        :email, :name, :password, :password_confirmation
      )
    end
end
