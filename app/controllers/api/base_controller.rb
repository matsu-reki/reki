#
# API の基底クラス
#
class Api::BaseController < ::ApplicationController

  skip_before_action :login_required

  rescue_from Reki::JsonBuildError, with: :render_error
  rescue_from Reki::RequestParseError, with: :render_bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :render_nothing

  private

    #
    # 400 エラーを返却する
    #
    def render_bad_request(exception = nil)
      logger.fatal %Q!#{$!} : #{$@.join("\n")}!
      render json: { error: ' 400 Bad Request' }, status: 500
    end

    #
    # 500 エラーを返却する
    #
    def render_error(exception = nil)
      logger.fatal %Q!#{$!} : #{$@.join("\n")}!
      render json: { error: '500 Internal Server Error' }, status: 500
    end

    #
    # 404 エラーを返却する
    #
    def render_nothing(exception = nil)
      logger.fatal %Q!#{$!} : #{$@.join("\n")}!
      render json: { error: '404 Not Found' }, status: 404
    end

end
