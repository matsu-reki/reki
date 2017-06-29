#
# インポートジョブのエラー内容
#
class ImportJobError < ApplicationRecord

  belongs_to :import_job

end
