require 'fileutils'
require 'enumerator'
require 'date'

namespace :backup do
  def date_prefix
    today = Date.today
    "#{today.year}-#{today.month}"
  end

  def folder
    File.join(Settings.backup.root, date_prefix)
  end

  def load_db_config
    db_config_file = Rails.root.join('config', 'database.yml').to_s
    YAML.load_file(db_config_file)[Rails.env].symbolize_keys
  end

  desc 'DBのダンプをSettings.backup.sync.serverで指定したサーバにアップロードする。ユーザ名はSettings.backup.sync.userで、保存先ディレクトリはSettings.backup.sync.folderで指定する。パスワードの入力を省略するには実行ユーザのホームディレクトリにpostgresqlのログイン設定ファイル「.pgpass」が必要'
  task db: :environment do
    FileUtils.mkdir_p(folder) unless File.exist?(folder)

    db_config = load_db_config

    filename = File.join(folder, "#{db_config[:database]}-#{Time.now.strftime("%Y%m%d%H%M%S")}.dump.sql.gz")
    cmd = "pg_dump -U #{db_config[:username]} "
    cmd << "-w "
    cmd << "#{db_config[:database]} | gzip > #{filename}"

    system cmd

    if Settings.backup.sync.user.present? && Settings.backup.sync.server.present? && Settings.backup.sync.folder.present?
      rsync_cmd = "rsync -a #{filename} #{Settings.backup.sync.user}@#{Settings.backup.sync.server}:#{Settings.backup.sync.folder}"
    end

    system rsync_cmd 

    # sync後にアップロード済みのファイルをディレクトリごと削除
    backup_path = Settings.backup.root
    system "rm -rf #{backup_path}"
  end
end
