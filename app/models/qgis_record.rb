#
# QGIS で管理するテーブルの基底クラス
#
class QgisRecord < ActiveRecord::Base

  self.abstract_class = true

  establish_connection(:qgis)

end
