#
# ログイン管理
#
class SessionsController < ApplicationController

  skip_before_action :login_required, only: %i(new create)

  #
  # ログイン画面表示
  #
  def new
    if current_user
      redirect_to root_path
      return
    end
  end

  #
  # ログイン
  #
  def create
    user = User.where(login: session_params[:login], enabled: true).first

    if user && user.authenticate(session_params[:password])
      login user
      redirect_to_login
    else
      flash[:alert] = t('.failure')
      redirect_to new_session_path
    end
  end

  #
  # ログアウト
  #
  def destroy
    logout
    redirect_to new_session_path
  end

  private

    def session_params
      params.fetch(:session, {}).permit(:login, :password)
    end

    # ログインセッションを作成する
    def login(user)
      session[:current_user] = user.id
    end

    # ログインセッションを削除する
    def logout
      session.clear
    end

    #
    # ログイン時のリダイレクト先を
    #
    def redirect_to_login(to_url = root_url)
      url = session[:access_to] || to_url
      redirect_to url
    end

end
