module ApplicationHelper

  #
  # Kaminari のページエントリ情報を表示
  #
  def entries_info(collection, options = {})
    entry_name = options[:entry_name] || collection.entry_name
    entry_name = entry_name.pluralize unless collection.total_count == 1

    if collection.total_pages < 2
      content = t('helpers.entries_info.one_page.display_entries',
          entry_name: entry_name,
          count: collection.total_count)
    else
      first = collection.offset_value + 1
      last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
      content = t('helpers.entries_info.more_pages.display_entries',
        entry_name: entry_name,
        first: first,
        last: last,
        total: number_with_delimiter(collection.total_count)
      )
    end

    return content_tag(:div, content.html_safe, class: "entries_info")
  end

  #
  # flash の内容をダイアログ表示するためのHTML要素を作る
  #
  def flash_dialog(options = {})
    html = content_tag(:div, id: 'flash-dialog', style: "display: none;") do
      inner_html = ''
      flash.each { |t, m| inner_html << flash_dialog_content(t, m) }
      flash.clear
      inner_html.html_safe
    end

    return html.html_safe
  end

  #
  # Kaminari のリンクに不要なパラメータが付与されるのを防ぐために、Kaminari
  # に渡すパラメータを修正する
  #
  def normalize_paginate_params(paginate_params = {} )
    new_params = {
      _: nil,
      _method: nil,
      authenticity_token: nil,
      utf8: nil,
      commit: nil
    }.merge(paginate_params)
    return new_params
  end

  #
  # 画面 body 要素に設定するユニーク ID を返す
  #
  def page_body_id
    @__page_body_id ||= "#{current_template.split('/').join('-')}"
    return  @__page_body_id
  end

  #
  # ページネーションにページ番号を表示するかどうか
  #
  def page_number_render?(page)
    return (page.left_outer? || page.right_outer? || page.inside_window?)
  end

  #
  # 画面のテンプレート名を返す
  #
  def page_template
    @__page_template ||= "#{current_template.split('/').last}"
    return  @__page_template
  end

  private

    #
    # flash 用ダイアログの中身を作る
    #
    def flash_dialog_content(type, message)
      icon = case type.to_sym
        when :success
          'done'
        when :error, :alert
          'warning'
        else
          'info'
      end

      html = content_tag(:div) do
        alert_title = content_tag(:i, icon, class: "left material-icons")
        alert_title += content_tag(:div, message, class: "left")
        alert_title.html_safe
      end
      return html.html_safe
    end

end
