#
# タグ名の使用不可文字（半角、全角空白）を検証する
#
class TagValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value =~ /[[:blank:]]|\,/
      if options[:message] && options[:value]
        record.errors.add attribute, options[:message], value: options[:value]
      else
        record.errors.add attribute, :not_an_tag
      end
    end
  end
end
