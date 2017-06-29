require 'reki/exceptions'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  if Rails.env.production?
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from Exception, with: :render_error
  end

  before_action :login_required

  helper_method :current_user, :logged_in?, :import_job_in_progress?

  #
  # ログイン中のユーザ
  #
  def current_user
    @current_user ||= User.find_by(id: session[:current_user])
    return @current_user
  end

  #
  # ログイン中かどうかを返す
  #
  def logged_in?
    return current_user.present?
  end

  #
  # 500 エラーページを表示する
  #
  def render_error
    respond_to do |format|
      format.html { render template: 'errors/500', status: 500 }
      format.js { render plain: { error: '500 error' }, status: 500 }
    end
  end

  #
  # 404 エラーページを表示する
  #
  def render_not_found
    respond_to do |format|
      format.html { render template: 'errors/404', status: 404 }
      format.js { render json: { error: '404 error' }, status: 404 }
      format.png { render plain: "404 error", status: 404 }
    end
  end

  private

    #
    # 管理者以外がアクセスした場合、トップページへリダイレクトする
    #
    def admin_required
      if current_user && !current_user.admin?
        redirect_to root_url, alert: t("shared.alert.admin_required")
      end
    end

    #
    # Flash メッセージを画面に表示する
    #
    def flash_message(type, options = {})
      target = ""
      target << "#{options[:model].model_name.human} " if options[:model]
      target << "#{options[:target]}" if options[:target]
      return t(type, scope: "shared.crud", target: target)
    end

    #
    # ログインセッションの有無を調べ、ログインセッションがない場合はログイン画面へ
    # リダイレクトする
    #
    def login_required
      unless current_user
        session[:access_to] = request.url
        redirect_to new_session_url, alert: t("shared.alert.login_required")
      end
    end

    #
    # インポートジョブが実行中でないこと
    #
    def import_job_not_in_progress
      if import_job_in_progress?
        redirect_to root_url, alert: t("shared.alert.import_job_in_progress")
      end
    end

    #
    # インポートジョブが実行中かどうかを返す
    #
    def import_job_in_progress?
      if @_import_job_in_progress.nil?
        @_import_job_in_progress = ImportJob.in_progress?
      end
      return @_import_job_in_progress
    end

    #
    # ページネーションの現在ページ数を返す
    #
    def page
      _page = params[:page].to_i rescue nil
      _page ||= 1
      return _page
    end

    #
    # ページネーションの1ページあたりの表示数を返す
    #
    def per_page
      _per_page = params[:limit].to_i rescue nil
      _per_page = 100 if _per_page.nil? || _per_page <= 0
      return _per_page
    end

end
