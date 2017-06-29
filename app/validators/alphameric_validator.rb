#
# 半角英数字かどうかをチェックする
#
class AlphamericValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[a-zA-Z0-9\_\-]+\z/
      if options[:message] && options[:value]
        record.errors.add attribute, options[:message], value: options[:value]
      else
        record.errors.add attribute, :not_an_alphameric
      end
    end
  end
end
