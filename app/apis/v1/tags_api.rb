module V1

  #
  # API v1 のタグ取得APIリクエスト
  #
  class TagsApi < BaseApi
    # クエリに指定可能な検索キー
    available_query_keys :created_at, :name, :updated_at

    # クエリに指定可能なソートキー
    available_sort_keys :created_at, :name, :updated_at

    #
    # タグ検索 API
    #
    def index(params)
      begin
        normalize_parmas(params)
        scoped = parse(Tag.enabled)
        tags = scoped.page(page).per(per_page)
        return build_response(tags)
      rescue
        Rails.logger.fatal %Q!#{$!} : #{$@.join("\n")}!
        raise Reki::JsonBuildError
      end
    end

    private

      #
      # レスポンスのページネーション情報を設定する
      #
      def build_pagination_response(tags, json)
        json[:pagination] = {
          count: tags.count,
          current_page: tags.current_page,
          per_page: tags.limit_value,
          total_count: tags.total_count,
          total_page: tags.total_pages
        }
        return json
      end

      #
      # タグ一覧の JSON を作成する
      #
      def build_response(tags)
        json = build_base_response(data: [])

        if tags.present?
          tags.each { |a| json[:data] << to_j(a) }
          build_pagination_response(tags, json)
        end

        return json
      end


      #
      # 指定したカラムを検索した結果を返す
      #
      def search(scoped, is_not, field, op, value)
        if field.present?
          arel_op, sql_op = query_op_to_ar(op)
          sql = case field.to_sym
            when :created_at, :updated_at
              validate_datetime(value)
              Tag.arel_table[field].send(arel_op, value)
            else
              Tag.arel_table[field].send(arel_op, value)
          end
          scoped = is_not ? scoped.where.not(sql): scoped.where(sql)
        else
          sql = Tag.arel_table[:name].matches(value)
          scoped = is_not ? scoped.where.not(sql): scoped.where(sql)
        end
        return scoped
      end

      #
      # ソート結果を返す
      #
      def sort(scoped, sort_key, order_key)
        return scoped.order(Tag.arel_table[sort_key].send(order_key))
      end

      #
      # タグ情報から JSON を作成する
      #
      def to_j(tag)
        json = {}

        # ID
        json[:id] = { type: "ic:識別値", label: "ID", value: tag.id }

        # 名称
        json[:name] = { type: "ic:名称", label: "名称", properties: [
          { type: "ic:表記", label: "名称（日本語）", value: tag.name }
        ]}

        json[:created_at] = { type: "ic:日時型", label: "登録日時", properties: [
          { type: "ic:標準型日時", label: "標準型日時", value: tag.created_at.try(:strftime, "%Y-%m-%dT%H:%M:%S") }
        ]}
        json[:updated_at] = { type: "ic:日時型", label: "更新日時", properties: [
          { type: "ic:標準型日時", label: "標準型日時", value: tag.updated_at.try(:strftime, "%Y-%m-%dT%H:%M:%S") }
        ]}

        return json
      end
  end
end
