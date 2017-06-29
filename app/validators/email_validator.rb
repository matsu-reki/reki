#
# E-Mail形式かどうかチェックを行なう
#
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      if options[:message] && options[:value]
        record.errors.add attribute, options[:message], value: options[:value]
      else
        record.errors.add attribute, :not_an_email
      end
    end

  end
end
