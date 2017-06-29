module ArchivesHelper

  #
  # 資料の分類選択セレクトボックスの内容
  #
  def archive_category_options(archive = nil)
    return options_from_collection_for_select(
      Category.enabled.order(:code),
      :id,
      :name,
      selected: archive.try(:category_id)
    )
  end

  #
  # 資料のライセンス選択セレクトボックスの内容
  #
  def archive_license_options(archive = nil)
    return options_from_collection_for_select(
      License.enabled.order(:code),
      :id,
      :name,
      selected: archive.try(:license_id)
    )
  end

end
