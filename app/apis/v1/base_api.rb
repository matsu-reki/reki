module V1

  #
  # API v1 のリクエストクラスの基底クラス
  #
  class BaseApi
    DATE_REGEX = {
      age: /\A\d{1,4}(-\d{1,2}){0,2}\z/,
      ymd: /\A\d{1,4}-\d{1,2}-\d{1,2}\z/,
      ymdhms: /\A\d{1,4}-\d{1,2}-\d{1,2}T\d{1,2}(\:\d{1,2}){1,2}\z/
    }
    INTEGER_REGEX = /\A[0-9]+\z/
    QUERY_REGEXP = /
      (
        (-)?                  # Minus
        (?:(\w+):)?           # Field
        (>=|<=|<|>)?          # Minus
        ([^\s]+)              # Single query
      )
    /x

    # レスポンス
    attr_reader :response

    # リクエストパラメータ
    attr_reader :params

    class << self

      #
      # ソート順に指定可能なキーを返す
      #
      def order_keys
        @order_keys ||= [:asc, :desc]
        return @order_keys
      end

      #
      # APIのクエリに使用できるキーを返す
      #
      def param_keys
        @param_keys ||= [:query, :sort, :order, :per_page, :page]
        return @param_keys
      end

      #
      # 検索に指定可能なキーを返す
      #
      def query_keys
        return @query_keys
      end

      #
      # ソートに指定可能なキーを返す
      #
      def sort_keys
        return @sort_keys
      end

      protected

        #
        # 検索に指定可能なキーを設定する
        #
        def available_query_keys(*keys)
          @query_keys = keys
        end

        #
        # ソートに指定可能なキーを設定する
        #
        def available_sort_keys(*keys)
          @sort_keys = keys
        end

    end


    protected

      #
      # JSON の共通部分を返す
      #
      def build_base_response(attributes = {})
         json = {
          namespace: {
            ic: Settings.imi.core,
            mr: Settings.imi.mr
          }
        }
        return json.merge(attributes)
      end

      #
      # リクエストパラメータから不要なパラメータを除去する
      #
      def normalize_parmas(params)
        @params = params.permit(self.class.param_keys).to_h
        return @params
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
      # 検索クエリを解析する
      #
      def parse(scoped)
        scoped = parse_query(scoped) if params[:query].present?
        scoped = parse_sort(scoped) if params[:sort].present?
        return scoped
      end

      #
      # クエリを解析
      #
      def parse_query(scoped)
        params[:query].scan(QUERY_REGEXP).each do |full, minus, field, op, value|
          if field.present? && !self.class.query_keys.include?(field.to_sym)
            raise Reki::RequestParseError, "#{field} is not available in query keys"
          end
          scoped = search(scoped, minus.present?, field, op, value)
        end
        return scoped
      end

      #
      # ソートを解析
      #
      def parse_sort(scoped)
        sort_key = params[:sort].to_sym
        order_key = (params[:order] || "asc").downcase.to_sym

        unless self.class.sort_keys.include?(sort_key)
          raise Reki::RequestParseError, "#{sort_key} is not available in sort keys"
        end

        unless self.class.order_keys.include?(order_key)
          raise Reki::RequestParseError, "#{order_key} is not available in order keys"
        end

        return sort(scoped, sort_key, order_key)
      end

      #
      # ページネーションの1ページあたりの表示数を返す
      #
      def per_page
        _per_page = params[:per_page].to_i rescue nil
        _per_page = 20 if _per_page.nil? || _per_page < 1 || _per_page > 100
        return _per_page
      end

      #
      # クエリ内の比較演算子を ActiveRecord 用の演算子に変換する
      #
      def query_op_to_ar(op)
        arel_op, sql_op = case op
          when ">=" then [:gteq, op];
          when "<=" then [:lteq, op];
          when ">"  then [:gt, op];
          when "<"  then [:lt, op];
          else [:eq, "="];
        end
        return [arel_op, sql_op]
      end

      #
      # 検索の結果を返す
      #
      def search(scoped, is_not, field, op, value)
        raise "OVERRIDE ME"
      end

      #
      # ソート結果を返す
      #
      def sort(scoped, sort_key, order_key)
        raise "OVERRIDE ME"
      end

      #
      # 日付形式のキーワードをチェックする
      #
      def validate_datetime(value)
        if value.match(DATE_REGEX[:ymdhms]) || value.match(DATE_REGEX[:ymd])
          datetime = DateTime.parse(value) rescue nil
          if datetime.nil?
            raise Reki::RequestParseError, "#{value} is not invalid datetime"
          end
        else
          raise Reki::RequestParseError, "#{value} is not invalid datetime"
        end
        return true
      end

      #
      # 数値形式のキーワードをチェックする
      #
      def validate_integer(value)
        unless value.match(INTEGER_REGEX)
          raise Reki::RequestParseError, "#{value} is not invalid integer"
        end
        return true
      end

  end
end
