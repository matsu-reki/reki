#
# 資料
#
class Archive < ApplicationRecord
  TILE_URL = Pathname.new(File.join("system", Rails.env, "tiles"))
  TILE_ROOT = Rails.root.join("public", "system", Rails.env, "tiles")
  TMP_TILE_ROOT = Rails.root.join("tmp", "tiles")

  include EnumAttribute

  # 年代(yyyy/mm/dd形式) DB保存時に reated_end_on_* カラムに値を設定する
  attr_accessor :created_begin_on

  # 年代(yyyy/mm/dd形式) DB保存時に reated_end_on_* カラムに値を設定する
  attr_accessor :created_end_on

  # 画像登録時に画像の内容を一時的に保存する変数
  attr_accessor :images

  # 緯度 保存時に geography(Point,4326) 形式に変換して lonlat に設定する
  attr_accessor :latitude

  # 経度 保存時に geography(Point,4326) 形式に変換して lonlat に設定する
  attr_accessor :longitude

  # 地図タイル画像の圧縮ファイル
  attr_accessor :map_file

  # 相関図作成用 先祖IDを格納する
  attr_accessor :parent_ids

  # 相関図作成用 連番
  attr_accessor :sequence_id

  # タグのラベル（カンマ区切りで複数指定可能） 保存時に archive_tags , tag
  # のレコードを作成する
  attr_accessor :tag_labels

  has_attached_file :represent_image,
    path: ":rails_root/public/system/:rails_env/:class/:attachment/:id/:filename",
    url: "/system/:rails_env/:class/:attachment/:id/:filename",
    styles: { original: "120x150#" }

  belongs_to :category
  belongs_to :license
  belongs_to :updated_user, class_name: "User", foreign_key: "updated_user_id"

  has_many :archive_assets, dependent: :destroy
  has_many :archive_tags, dependent: :destroy
  has_many :tags,  -> { order(:name) }, through: :archive_tags

  delegate :name, :code, to: :category, prefix: true
  delegate :name, to: :updated_user, prefix: true
  delegate :url, to: :license, prefix: true

  validates :author, presence: true, length: { maximum: 100 }
  validates :category_id, presence: true
  validates :description, presence: true
  validates :enabled, inclusion: { in: [true, false] }
  validates :latitude, numericality: { allow_blank: true }
  validates :longitude, numericality: { allow_blank: true }
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :owner, presence: true, length: { maximum: 100 }

  validate :validate_created_on, :validate_lonlat, :validate_tags, :validate_map

  validates_attachment :represent_image, presence: true,
    content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

  # 公開中の資料
  scope :enabled, -> { where(enabled: true) }

  # 複数のフィールドのいずれか部分一致するレコードを返す
  scope :keyword_cont_any, -> (k) { where(keyword_cont_any_sql(k)) }

  # 複数のフィールドのいずれか部分一致しないレコードを返す
  scope :keyword_not_cont_any, -> (k) { where.not(keyword_cont_any_sql(k)) }

  # 指定した緯度, 経度の半径nメートル以内のレコードを返す
  scope :near, ->(lonlat, radius) {
    where("ST_DWithin(lonlat, ?, ?)", lonlat, radius)
  }

  before_save :prepare_lonlat, :prepare_created_on
  after_save :prepare_images, :prepare_tags, :prepare_maptile

  class << self
    #
    # キーワード検索用の SQL を返す
    #
    def keyword_cont_any_sql(keyword)
      sql = %i(name description owner author).map do |c|
        Archive.arel_table[c].matches("%#{sanitize_sql_like(keyword)}%").to_sql
      end
      return sql.join(" OR ")
    end
  end

  # 画像数が上限かどうかを返す
  def assets_limit?
    return archive_assets.count >= Settings.archive.assets.maximum
  end

  # 資料の相関図用のハッシュを返却する
  def chart
    data = {}
    nodes, links = make_tree
    data[:nodes] = nodes
    data[:links] = links
    return data
  end

  # 相関図の木構造を作成する
  def make_tree
    nodes = []
    links = []
    except_ids = [id] #除外するid(一度登場したノードは再度登場させない)
    store = []
    # rootを先祖と連番を設定してからキューに追加
    root = self
    root.parent_ids = []
    root.sequence_id = 0
    store.push(root)
    while store.present? do
      # archive ← キューから取り出す
      archive = store.shift
      children = Archive.enabled.joins(:tags)
        .where('tags.id' => archive.tags.ids)
        .where.not('archives.id' => except_ids)
        .distinct.order('archives.created_at asc')
      nodes << { id: archive.sequence_id, archive_id: archive.id, label: archive.name, file: archive.represent_image.url }

      # rootからの距離制限
      tmp_parent_ids = archive.parent_ids + [archive.id]
      if tmp_parent_ids.size > Settings.archive.relations.maximum
        break
      end

      children.each do |child|
        except_ids << child.id
        # archiveを先祖と連番を設定してからキューに追加
        child.parent_ids = tmp_parent_ids
        child.sequence_id = except_ids.size - 1
        store.push(child)
        links << { source: archive.sequence_id, target: child.sequence_id, target_archive_id: child.id, distance: child.parent_ids.size }
      end
    end

    return nodes, links
  end

  # 地図タイル画像のURL
  def maptile_url
    tile_url_root = TILE_URL.join(id)
    tile_root = TILE_ROOT.join(id)
    if Dir.exist?(tile_root)
      url = ActionController::Base.helpers.asset_path(
          tile_url_root.join("{z}/{x}/{y}.png"),
          host: Settings.application.url
       )
    else
      url = nil
    end
    return url
  end

  #
  # DBの設定値からインスタンス変数の値を設定する
  #
  # after_initialize でよびだすと、検索に影響するので注意すること
  #
  def prepare_instance_attributes
    self.created_begin_on ||= to_created_on_s(
      created_begin_on_y, created_begin_on_m, created_begin_on_d
    )
    self.created_end_on ||= to_created_on_s(
      created_end_on_y, created_end_on_m, created_end_on_d
    )

    if lonlat
      self.longitude ||= lonlat.x
      self.latitude ||= lonlat.y
    end

    self.tag_labels ||= tags.pluck(:name).join(",")
  end

  private

    #
    # 画像を保存する
    #
    # 更新の際は、前回登録した画像は全て削除後、新規ファイルで再登録を行う
    #
    def prepare_images
      if images.present?
        ArchiveAsset.where(archive_id: id).destroy_all
        images.each { |i| self.archive_assets.create(image: i) }
      end

      return self
    end

    #
    # 年代文字列から年代数値を設定する
    #
    def prepare_created_on
      if created_begin_on.present?
        self.created_begin_on_y,
          self.created_begin_on_m,
            self.created_begin_on_d = to_created_on_i(created_begin_on)
      end

      if created_end_on.present?
        self.created_end_on_y,
          self.created_end_on_m,
            self.created_end_on_d = to_created_on_i(created_end_on)
      end

      return self
    end

    #
    # 地図のタイル画像を解凍する
    #
    def prepare_maptile
      if map_file.present?
        tmp_dir = TMP_TILE_ROOT.join(id)
        tile_dir = TILE_ROOT.join(id)

        # 必要なディレクトリを作る
        FileUtils.mkdir_p(TILE_ROOT) unless Dir.exists?(TILE_ROOT)
        FileUtils.mkdir_p(TMP_TILE_ROOT) unless Dir.exists?(TMP_TILE_ROOT)

        # 不要なディレクトリを消す
        FileUtils.rm_r(tmp_dir) if Dir.exists?(tmp_dir)
        FileUtils.rm_r(tile_dir) if Dir.exists?(tile_dir)

        system("unzip -d #{tmp_dir} #{map_file.path} > /dev/null")

        # zipファイル内のルートディレクトリは不要なので削除する
        entries = Dir.glob("#{tmp_dir}/*/")
        if entries.size == 1
          FileUtils.mv entries.first, tile_dir
        elsif entries.size > 1
          FileUtils.mv tmp_dir, tile_dir
        end
      end

      return self
    end

    #
    # tag_labels からタグの内容を作成する
    #
    def prepare_tags
      if tag_labels.blank?
        return
      end

      new_tags = []
      registerd_tag_ids = []

      tag_labels.split(",").uniq.each do |t|
        if t.present?
          new_tag = Tag.find_by(name: t)
          new_tag = Tag.new(name: t, enabled: true) if new_tag.nil?
          registerd_tag = tags.find_by(name: t)

          if registerd_tag.present?
            registerd_tag_ids << registerd_tag.id
          else
            new_tags << new_tag
          end
        end
      end


      # 不要なタグを削除する
      archive_tags.each do |at|
        unless registerd_tag_ids.include?(at.tag.id)
          at.destroy
        end
      end

      # 新しいタグを追加する
      new_tags.each do |nt|
        nt.save if nt.new_record?
        archive_tags.create(tag_id: nt.id)
      end
    end

    #
    # 緯度・経度から lonlat カラムの値を設定する
    #
    def prepare_lonlat
      if longitude && latitude
        self.lonlat = "POINT(#{longitude} #{latitude})"
      end

      return self
    end

    #
    # 年代文字列から、年代数値に変換する
    # 未入力の場合は nil を設定する
    #
    # 2014/1/1 -> 2014,1,1
    # 2014/1   -> 2014,1,0
    # 2014     -> 2014,0,0
    #
    def to_created_on_i(text)
      i = text.split("/")
      if i.size > 0
        y = 0
        m = 0
        d = 0

        y = i[0].to_i if i.size >= 1
        m = i[1].to_i if i.size >= 2
        d = i[2].to_i if i.size >= 3
      else
        y = nil
        m = nil
        d = nil
      end

      return [y ,m, d]
    end

    #
    # 年代数値から年代文字列に変換する
    #
    # 20140101 -> 2014/1/1
    #
    def to_created_on_s(y,m,d)
      s = ""
      s << "#{y}"  if y.present?
      s << "/#{m}" if m.present? && m != 0
      s << "/#{d}" if d.present? && d != 0
      return s
    end

    #
    # 年代を検証する
    #
    def validate_created_on
      regex = /\A(\d{1,4})(\/\d{1,2})?(\/\d{1,2})?\z/

      if created_begin_on.present? && created_begin_on !~ regex
        errors.add :created_begin_on, :invalid
      end

      if created_end_on.present? && created_end_on !~ regex
        errors.add :created_end_on, :invalid
      end

      if created_begin_on.present? && created_end_on.present? &&
          created_begin_on > created_end_on
        errors.add :created_end_on, :invalid
      end
    end

    #
    # 緯度・経度を検証する
    #
    # 両方の値が設定されている、または設定されていない事を検証する
    #
    def validate_lonlat
      if latitude.present? && longitude.blank?
        errors.add :longitude, :blank
      end

      if longitude.present? && latitude.blank?
        errors.add :latitude, :blank
      end
    end

    #
    # 地図タイプの資料の場合、タイル画像のファイルがない場合エラー
    #
    def validate_map
      if new_record? && map_file.present?
        if File.extname(map_file.path).downcase != '.zip' ||
          map_file.size == 0
          errors.add :map_file, :invalid
        end
      end
    end

    #
    # タグの内容を検証する
    #
    def validate_tags
      if tag_labels.blank?
        return
      end

      count = 0

      tag_labels.split(",").each do |t|
        if t.present?
          count += 1
          tag = Tag.find_by(name: t)
          tag ||= Tag.new(name: t)
          unless tag.valid?
            errors.add :base, tag.errors.full_messages.join(",")
          end
        end
      end

      if count > Settings.archive.tag.maximum
        errors.add :tag_labels, :less_than_or_equal_to, count: Settings.archive.tag.maximum
      end
    end
end
