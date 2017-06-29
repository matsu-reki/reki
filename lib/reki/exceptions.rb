module Reki

  #
  # JSON 作成時の例外
  #
  class JsonBuildError < StandardError; end

  #
  # API のリクエスト解析時の例外
  #
  class RequestParseError < StandardError; end


end
