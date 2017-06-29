ActionView::Base.field_error_proc = Proc.new do |tag, instance|
  if tag =~ /<(input|label|textarea|select)/
    tag = Nokogiri::HTML::DocumentFragment.parse(tag)
    tag.children.add_class 'invalid'
    tag.to_s.html_safe
  else
    html_tag
  end
end
