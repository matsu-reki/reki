#
# QGISの資料データ
#
class QgisPhoto < QgisRecord
  self.table_name = 't_photo'
  self.primary_key = 'p_id'

  #
  # インポート処理
  #
  # 別のインポート初理が実行中の場合は処理を行わない
  # インポート処理が開始可能な場合は ImportJob を作成し、各種データ変更を排他制御する
  #
  def self.import(user: nil, force: false)

    if force
      ImportJob.delete_all
    else
      if ImportJob.in_progress?
        return ImportJob::Result.new.locked!
      end
    end

    job = ImportJob.create(user_id: user.try(:id), state: 'progress')

    self.delay.run_import(job)

  end

  private

    #
    # インポート処理
    #
    def self.run_import(job)
      result = nil

      begin
        self.transaction do
          result = imoport_transction(job)
          delete_transction job.created_at
        end
      rescue
        ;
      ensure
        # １件も登録でなかった場合はジョブの履歴を残さない
        if result.present?
          if result.count > 0
            job.update(state: 'done')
          else
            job.destroy
          end
        else
          job.destroy
        end
      end
    end

    #
    # インポート処理
    #
    def self.imoport_transction(job)
      result = ImportJob::Result.new

      begin
        file_root = Settings.qgis.image.root

        batch = 100
        cursor = 0
        default_category = Category.default
        default_license = License.default
        default_image = File.new(Rails.root.join("public", "no_image.png").to_s)

        photos = QgisPhoto.all

        latest = ImportJob.latest
        if latest.present?
          photos = photos.where(QgisPhoto.arel_table[:mdate].gt(latest.created_at))
        end

        total = photos.count

        result.total = total

        while total >= cursor do
          photos = photos.order(:landmark_id, :p_id).offset(cursor).limit(batch)
          cursor += batch
          archives = Array.new

          photos.each do |photo|
            if photo.landmark_id.present?
              same_group_archive = Archive.where.not(qgis_id: photo.p_id).
                where(qgis_group_id: photo.landmark_id).first

              # 同じ landmark_id を持つ資料はひとつの資料として扱う
              if same_group_archive.present?
                same_group_archive.archive_assets.create image: File.new(File.join(file_root, "1-1.jpg"))
                result.count += 1
                next
              end
            end

            archive = Archive.find_or_initialize_by(qgis_id: photo.p_id)
            archive.name = photo.filename
            archive.category_id = default_category.id
            archive.license_id = default_license.id

            archive.note = photo.notes
            archive.longitude = photo.lon
            archive.latitude = photo.lat

            # キーワードからタグを生成する
            archive.tag_labels = Tag.generate(photo.keywords).join(".")

            # 資料の画像を読み込む
            # 画像が見つからない場合はデフォルトの画像（NoImage）を設定する
            image_path = File.join(file_root, photo.filename)
            image_exist = File.exist?(image_path)
            if image_exist
              image = File.new(image_path)
            else
              image = default_image
            end

            image_no = rand(1..10)
            archive.description = "説明"
            archive.owner  = "松江歴史館"
            archive.author = "作者不明"
            archive.represent_image = image

            archive.enabled = false
            archive.qgis_id = photo.p_id
            archive.qgis_group_id = photo.landmark_id

            if archive.save
              # 画像が見つかった場合だけassetのレコードを作る
              if image_exist
                asset = archive.archive_assets.where(qgis_id: photo.p_id).first
                asset = archive.archive_assets.build if asset.blank?
                asset.image = image
                asset.qgis_id = photo.p_id
                asset.qgis_group_id = photo.landmark_id
                asset.save!
              end
              result.count += 1
            else
              job.import_job_errors.create(
                name: photo.filename,
                content: archive.errors.full_messages.join("\n")
              )
              result.error!
            end
          end
        end

      rescue
        Rails.logger.fatal %Q!#{$!} : #{$@.join("\n")}!
        result.fatal!
      end

      return result
    end

    #
    # QGISのデータベースから削除された
    #
    def self.delete_transction(procceed_at)
      delete_asset_ids = Array.new
      delete_archive_ids = Array.new

      ArchiveAsset.where(ArchiveAsset.arel_table[:qgis_id].not_eq(nil)).
        where(ArchiveAsset.arel_table[:updated_at].lt(procceed_at)).
        find_each(:batch_size => 100).pluck(:id, :qgis_id).each do |id, qgis_id|
        unless QgisPhoto.where(p_id: qgis_id).exists?
          delete_asset_ids << id
        end
      end

      Archive.where(Archive.arel_table[:qgis_id].not_eq(nil)).
        where(Archive.arel_table[:updated_at].lt(procceed_at)).
        find_each(:batch_size => 100).pluck(:id, :qgis_id).each do |id, qgis_id|
        unless QgisPhoto.where(p_id: qgis_id).exists?
          delete_archive_ids << id
        end
      end

      if delete_archive_ids.present?
        Archive.where(id: delete_archive_ids).destroy
      end

      if delete_archive_ids.present?
        Archive.where(id: delete_archive_ids).destroy
      end
    end
end
