module V1

  #
  # API v1 のタグ取得APIリクエスト
  #
  class ArchivesApi < BaseApi

    # クエリに指定可能な検索キー
    available_query_keys :author, :category, :created_begin_on, :created_at, :created_end_on,
      :description, :location, :note, :name, :owner, :tag, :updated_at
    # クエリに指定可能なソートキー
    available_sort_keys :author, :created_begin_on, :created_at, :created_end_on,
      :description, :location, :note, :name, :owner, :updated_at

    #
    # 資料検索 API
    #
    def all(params)
      normalize_parmas(params)
      scoped = parse(Archive.enabled.includes(:tags, :category).references(:tags, :category))
      archives = scoped.page(page).per(per_page)
      return build_index_response(archives)
    end

    #
    # 資料詳細 API
    #
    def show(params)
      normalize_parmas(params)
      archive = Archive.enabled.find(params[:id])
      return build_show_response(archive)
    end

    #
    # 資料関連 API
    #
    def chart(params)
      normalize_parmas(params)
      archive = Archive.find(params[:id])
      chart = archive.chart
      return build_chart_response(chart)
    end

    #
    # 資料近隣 API
    #
    def near(params)
      normalize_parmas(params)
      archive = Archive.find(params[:id])
      if archive.lonlat
        radius = @params[:radius] || 1000
        archives = Archive.enabled.near(archive.lonlat, radius)
          .order(
            "archives.created_begin_on_y ASC NULLS LAST,archives.created_begin_on_m ASC NULLS LAST,archives.created_begin_on_d ASC NULLS LAST"
          )
      else
        archives = Archive.none
      end
      archives = archives.page(page).per(per_page)
      return build_index_response(archives)
    end

    private

      #
      # 資料検索 API のレスポンス JSON を作成する
      #
      def build_index_response(archives)
        begin
          json = build_base_response(data: [])

          if archives.present?
            archives.each { |a| json[:data] << to_j(a, type: :index) }
            build_pagination_response(archives, json)
          end

          return json
        rescue
          Rails.logger.fatal %Q!#{$!} : #{$@.join("\n")}!
          raise Reki::JsonBuildError
        end
      end

      #
      # レスポンスのページネーション情報を設定する
      #
      def build_pagination_response(archives, json)
        json[:pagination] = {
          count: archives.count,
          current_page: archives.current_page,
          per_page: archives.limit_value,
          total_count: archives.total_count,
          total_page: archives.total_pages
        }
        return json
      end

      #
      # 資料詳細 API のレスポンス JSON を作成する
      #
      def build_show_response(archive)
        begin
          json = build_base_response(data: nil)
          json[:data] = to_j(archive, type: :show)
          return json
        rescue
          Rails.logger.fatal %Q!#{$!} : #{$@.join("\n")}!
          raise Reki::JsonBuildError
        end
      end

      #
      # 資料からJSON を作成する
      #
      def build_chart_response(chart)
        begin
          json = build_base_response(data: nil)
          json[:data] = to_j_chart(chart)
          return json
        rescue
          Rails.logger.fatal %Q!#{$!} : #{$@.join("\n")}!
          raise Reki::JsonBuildError
        end
      end

      #
      # 年代を検索する SQL を返す
      #
      def create_on_sql(field, op, value)
        year = 0
        month = 0
        day = 0

        if value.match(DATE_REGEX[:age])
          year, month, day = value.split("-")
        else
          raise Reki::RequestParseError, "#{value} is invalid date"
        end

        month ||= 0
        day ||= 0

        return [
          "(\"archives\".\"#{field}_y\" * 10000 +\"archives\".\"#{field}_m\" * 100 + \"archives\".\"#{field}_d\") #{op} ?",
          (year.to_i * 10000 + month.to_i * 100 + day.to_i)
        ]
      end

      #
      # 指定したカラムを検索した結果を返す
      #
      def search(scoped, is_not, field, op, value)
        if field.present?
          arel_op, sql_op = query_op_to_ar(op)
          sql = case field.to_sym
            when :created_begin_on, :created_end_on
              create_on_sql(field, sql_op, value)
            when :created_at, :updated_at
              validate_datetime(value)
              Archive.arel_table[field].send(arel_op, value)
            when :category
              Category.arel_table[:name].send(arel_op, value)
            when :tag
              Tag.arel_table[:name].send(arel_op, value)
            else
              Archive.arel_table[field].send(arel_op, value)
          end
          scoped = is_not ? scoped.where.not(sql): scoped.where(sql)
        else
          scoped = is_not ? scoped.keyword_not_cont_any(value) : scoped.keyword_cont_any(value)
        end
        return scoped
      end

      #
      # 検索結果をソートする
      #
      def sort(scoped, sort_key, order_key)
        case sort_key
          when :created_begin_on
            scoped = scoped.order(
              Archive.arel_table[:created_begin_on_y].send(order_key),
              Archive.arel_table[:created_begin_on_m].send(order_key),
              Archive.arel_table[:created_begin_on_d].send(order_key),
            )
          when :created_end_on
            scoped = scoped.order(
              Archive.arel_table[:created_end_on_y].send(order_key),
              Archive.arel_table[:created_end_on_m].send(order_key),
              Archive.arel_table[:created_end_on_d].send(order_key),
            )
          else
            scoped = scoped.order(Archive.arel_table[sort_key].send(order_key))
        end
        return scoped
      end

      #
      # 資料情報をJSONに変換する
      #
      def to_j(archive, options = {})
        json = {}

        archive.prepare_instance_attributes

        # ID
        json[:id] = { type: "ic:識別値", label: "ID", value: archive.id }

        # 分類
        json[:category] = { type: "ic:コード", label: "分類コード", properties: [
          { type: "ic:識別子", label: "分類コード", value: archive.category_code },
          { type: "ic:表記", label: "分類名", value: archive.category_name }
        ]}

        # 名称
        json[:name] = { type: "ic:名称", label: "名称", properties: [
          { type: "ic:表記", label: "名称（日本語）", value: archive.name }
        ]}

        # 分類
        json[:description] = { type: "ic:説明", label: "説明", value: archive.description }

        if archive.lonlat.present?
          json[:coordinate] = { type: "ic:座標", label: "位置情報", properties: [
            { type: "ic:座標参照系", label: "座標参照系", properties: [
              { type: "ic:識別子", label: "コード", value: "4326" }
            ]},
            { type: "ic:緯度", label: "緯度", value: archive.lonlat.y },
            { type: "ic:経度", label: "経度", value: archive.lonlat.x }
          ]}
        end

        maptile_url = archive.maptile_url
        if maptile_url.present?
          json[:maptile] = {
            type: "mr:地図",
            label: "地図タイルURL",
            value: maptile_url
          }
        end

        # 年代（始期）
        if archive.created_begin_on.present?
          json[:created_begin_on] = {
            type: "mr:年代始期",
            label: "年代（始期）",
            properties: [] }

          if archive.created_begin_on_y.present?
            json[:created_begin_on][:properties] << {
              type: "ic:年",
              label: "年",
              value: archive.created_begin_on_y
            }
          end

          if archive.created_begin_on_m.present?
            json[:created_begin_on][:properties] << {
              type: "ic:月",
              label: "月",
              value: archive.created_begin_on_m
            }
          end

          if archive.created_begin_on_d.present?
            json[:created_begin_on][:properties] << {
              type: "ic:日",
              label: "日",
              value: archive.created_begin_on_d
            }
          end
        end

        # 年代（終期）
        if archive.created_end_on.present?
          json[:created_end_on] = {
            type: "mr:年代終期",
            label: "年代（終期）",
            properties: []
          }

          if archive.created_end_on_y.present?
            json[:created_end_on][:properties] << {
              type: "ic:年",
              label: "年",
              value: archive.created_end_on_y
            }
          end

          if archive.created_end_on_m.present?
            json[:created_end_on][:properties] << {
              type: "ic:月",
              label: "月",
              value: archive.created_end_on_m
            }
          end

          if archive.created_end_on_d.present?
            json[:created_end_on][:properties] << {
              type: "ic:日",
              label: "日",
              value: archive.created_end_on_d
            }
          end
        end

        # サムネイル画像
        json[:represent_image] = {
          type: "ic:サムネイル画像",
          label: "サムネイル画像",
          value: ActionController::Base.helpers.image_path(
            archive.represent_image.url,
            host: Settings.application.url)
        }

        # 画像
        if archive.archive_assets.present?
          json[:images] = []
          archive.archive_assets.each do |a|
            json[:images] << {
              type: "ic:画像",
              label: "画像",
              value: ActionController::Base.helpers.image_path(
                a.image.url(:original),
                host: Settings.application.url
              )
            }
          end
        end

        # 作者
        json[:author] = { type: "mr:作者", label: "名称", properties: [
          { type: "ic:表記", label: "作者（日本語）", value: archive.author }
        ]}

        # 所有者
        json[:owner] = { type: "mr:所有者", label: "名称", properties: [
          { type: "ic:表記", label: "所有者（日本語）", value: archive.owner }
        ]}

        json[:note] = { type: "ic:備考", label: "備考", value: archive.note }

        json[:license] = {
          type: "mr:ライセンス",
          label: "ライセンス",
          value: archive.license_url
        }

        json[:created_at] = { type: "ic:登録日時", label: "登録日時", properties: [
          { type: "ic:標準型日時",
            label: "標準型日時",
            value: archive.created_at.try(:strftime, "%Y-%m-%dT%H:%M:%S")
          }
        ]}

        json[:updated_at] = { type: "ic:更新日時", label: "更新日時", properties: [
          { type: "ic:標準型日時",
            label: "標準型日時",
            value: archive.updated_at.try(:strftime, "%Y-%m-%dT%H:%M:%S")
          }
        ]}

        # タグ
        if options[:type] == :show && archive.tags.present?
          json[:tags] = []
          archive.tags.order(:name).each do |t|
            json[:tags] << { type: "mr:タグ", label: "タグ", properties: [
              { type: "ic:識別値", label: "タグID", value: t.id },
              { type: "ic:表記", label: "タグ", value: t.name }
            ]}
          end
        end

        return json
      end

      #
      # 相関情報をJSONに変換する
      #
      def to_j_chart(chart)
        json = {}
        json[:nodes] = []

        chart[:nodes].each do |node|
          node_hash = {}
          #ノードID
          node_hash[:id] = { type: "ic:識別値", label: "ID", value: node[:id] }

          #archive ID
          node_hash[:archive_id] = {
            type: "ic:識別値", label: "資料ID", value: node[:archive_id]
          }
          # 名称
          node_hash[:label] =
          { type: "ic:名称", label: "名称", properties: [
              { type: "ic:表記", label: "名称（日本語）", value: node[:label] }
          ]}
          # サムネイル画像
          node_hash[:file] = {
             type: "ic:画像",
             label: "サムネイル画像",
             value: ActionController::Base.helpers.image_path(
                node[:file],
                host: Settings.application.url
             )
           }
          json[:nodes] << node_hash
        end

        json[:links] = []
        chart[:links].each do |link|
          link_hash = {}
          # 親ノードID
          link_hash[:source] = {
            type: "ic:識別値", label: "親ノードID", value: link[:source]
          }

          # 子ノードID
          link_hash[:target] = {
            type: "ic:識別値", label: "子ノードID", value: link[:target]
          }
          # 距離
          link_hash[:distance] = {
            type: "ic:長さ", label: "距離", value: link[:distance]
          }
          json[:links] << link_hash
        end
        return json
      end
  end

end
