#
# ActionView に表示中のテンプレートファイル名を取得するアクセサを追加
#

module CurrentTemplateAccessor
  def render_template(template, layout_name = nil, locals = {})
    @view.current_template ||= template.try(:virtual_path)
    super
  end
end

ActionView::Base.class_eval do
  attr_accessor :current_template
end

class ActionView::TemplateRenderer
  prepend CurrentTemplateAccessor
end
