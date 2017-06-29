#
# Enum の属性値を翻訳する
#
module EnumAttribute

  extend ActiveSupport::Concern

  included do
    #
    # @override
    #
    # enum 定義時に属性値翻訳用のメソッドを追加する
    #
    def self.enum( definitions )
      super( definitions )
      definitions.each do |name, _|
        define_attr_i18n_method(self, name)
      end
    end
  end

  module ClassMethods

    #
    # 指定した enum の翻訳表記を返す
    #
    def translate_enum_label(attr_name, enum_label)
      ::I18n.t("activerecord.enums.#{self.to_s.underscore}.#{attr_name}.#{enum_label}", default: enum_label)
    end

    #
    # i18n 用のメソッドを追加する
    #
    def define_attr_i18n_method(klass, attr_name)
      attr_i18n_method_name = "#{attr_name}_t"

      klass.class_eval <<-METHOD, __FILE__, __LINE__
      def #{attr_i18n_method_name}
        enum_label = self.send(:#{attr_name})
        if enum_label
          self.class.translate_enum_label(:#{attr_name}, enum_label)
        else
          nil
        end
      end
      METHOD
    end
  end
end
