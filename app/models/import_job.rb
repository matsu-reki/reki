#
# QGISのデータインポート処理
#
# データインポート中は各種データの変更ができないよう排他制御する
#
class ImportJob < ApplicationRecord
  include EnumAttribute

  # データインポート処理の進行状況
  enum state: {
    progress: 0,  # 実行中
    done: 1       # 完了
  }

  belongs_to :user
  has_many :import_job_errors, dependent: :destroy

  delegate :name, to: :user, prefix: true

  #
  # データインポート処理が実行中可動化を返す
  #
  def self.in_progress?
    return ImportJob.progress.exists?
  end

  #
  # 最新のデータインポート履歴を取得する
  #
  def self.latest
    return ImportJob.done.order(updated_at: :desc).first
  end

  class Result
    attr_accessor :count, :total
    attr_reader :status, :errors

    # 初期化
    def initialize
      @count = 0
      @total = 0
      @status = 0
      @errors = Hash.new
    end

    #
    # インポート処理のエラー内容を設定する
    #
    def error(qgis_id, messages)
      @status = 2
      @errors[qgis_id] = messages
      return self
    end

    #
    # インポート処理がデータ不備で終了
    #
    def error!
      @status = 2
      return self
    end

    #
    # インポート処理が予期せぬエラーで終了
    #
    def fatal!
      @status = 9
      return self
    end

    #
    # 別ジョブ実行中のため、ジョブを中止した
    #
    def locked!
      @status = 1
      return self
    end

    # ジョブが成功
    def success!
      @status = 0
      return self
    end

    # ジョブが成功したかを返す
    def success?
      return @status == 0
    end

  end
end
