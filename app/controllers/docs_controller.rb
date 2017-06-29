#
# ドキュメントを表示するコントローラ
#
class DocsController < ApplicationController
  layout 'docs'

  skip_before_action :login_required

  #
  # 共通語彙基盤 各種ドキュメントへの索引
  #
  def index
  end

  #
  # 共通語彙基盤 カスタムクラスの説明書
  #
  def imi
  end

end
