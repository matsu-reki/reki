# 松江G空間プロジェクト 資料管理システム

### 必須パッケージのインストール

 * Debian jessie の場合

```bash
$ sudo apt-get install postgresql postgresql-contrib postgresql-9.4-postgis-2.1 libpq-dev
$ sudo apt-get install mecab libmecab-dev mecab-ipadic-utf8
$ sudo apt-get install libmagickwand-dev
$ sudo apt-get install libxml2
```

### `資料管理システム`のセットアップ

```bash
$ cd RAILS_ROOT
$ cp config/database.yml{.sample,}
$ vi config/database.yml
$ bundle install --path vendor/bundle
$ bundle exec rake db:setup
```

### `資料管理システム`を起動する

```bash
$ cd RAILS_ROOT
$ bunde exec rails server
```

### `資料管理システム`を利用する

* ブラウザで 'http://localhost:3000/signin' にアクセスする
* ログイン画面で以下の内容を入力する
  * ID: admin
  * パスワード: password
