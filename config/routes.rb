Rails.application.routes.draw do
  root to: "archives#index"

  get 'signin' => 'sessions#new'
  delete 'signout' => 'sessions#destroy'

  # 資料
  resources :archives do
    collection do
      # タグ自動生成
      get :extract_tag
      patch :update_enabled
    end

    member do
      get :edit_image
      get :edit_tag
      patch :update_image
    end

    # 資料画像管理
    resources :archive_assets, except: %i(show)
  end

  # オンラインドキュメント
  resources :docs, only: %i(index) do
    collection do
      get :imi
    end
  end

  # ライセンス
  resources :licenses, only: %i(show)

  # ログイン管理
  resources :sessions, only: %i(new create destroy)

  # パスワード変更
  resources :users, only: %i(edit update)

  # 管理者向け機能
  namespace :admin do
    # 資料分類
    resources :categories, except: %i(show)

    # データインポート
    resources :import_jobs, only: %i(index show create)

    # ライセンス
    resources :licenses

    # タグ禁止用語
    resources :tag_black_lists, except: %i(show)

    # タグ
    resources :tags, except: %i(show)

    # ユーザ
    resources :users, except: %i(show)
  end

  # API
  namespace :api do
    # Version 1

    namespace :v1 do
      # 資料取得
      resources :archives, only: %i(index show) do
        member do
          get :chart
          get :near
        end
      end

      # タグ取得
      resources :tags, only: %i(index)
    end
  end

  get '*path', controller: 'application', action: 'render_not_found'

end
