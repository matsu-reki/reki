#
# タグのAPI
#
class Api::V1::TagsController < Api::BaseController

  #
  # タグ一覧を JSON 形式で返却する API
  #
  def index
    render json: ::V1::TagsApi.new.index(params)
  end

end
