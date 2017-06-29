#
# 資料のAPI
#
class Api::V1::ArchivesController < Api::BaseController

  #
  # 資料一覧を JSON 形式で返却する API
  #
  def index
    render json: ::V1::ArchivesApi.new.all(params)
  end

  #
  # 資料の詳細を JSON 形式で返却する API
  #
  def show
    render json: ::V1::ArchivesApi.new.show(params)
  end

  #
  # 資料の座標付近の資料一覧を JSON 形式で返却する API
  #
  def near
    render json: ::V1::ArchivesApi.new.near(params)
  end

  #
  # 相関図情報を JSON 形式で返却する API
  #
  def chart
    render json: ::V1::ArchivesApi.new.chart(params)
  end

end
