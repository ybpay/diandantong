Ddt::Core::Engine.add_routes do

  # WeChat server auth files
  get '/MP_(:hash).txt' => 'common/weixin#wechat_server_auth_file', as: :wechat_server_auth_file1
  get '/mp/MP_(:hash).txt' => 'common/weixin#wechat_server_auth_file', as: :wechat_server_auth_file2
  get '/q/:id', to: 'common/qr_code_scenes#show', as: :qr_code

  namespace :common do
    post 'js_error_report' => 'js_error_report#create', as: :js_error_report
    post 'cloopen_call_resp' => 'cloopen_call_resp#create', as: :cloopen_call_resp
    post 'weixin_oauth_callback' => 'weixin#weixin_oauth_callback'
    get 'wechat_account_oauth_callback' => 'weixin#wechat_account_oauth_callback'
    resources :shops do
      get '/api' => 'messages#validate', as: :gh_config_api
      post '/api' => 'messages#create', as: :message_create_root
      resources :qr_code_scenes, only: [:show]
      resources :verify_vip_info_qr_code_scenes, only: [:show] do
        get :verify, on: :member
      end
      resource :verify_vip_info, only: [:show] do
        get :verify
      end
      resources :reporters, only: [:index] do
        get :show, on: :collection
      end
    end
    get 'clear_cookies' => 'clear_cookies#clear_cookies', as: :clear_cookies if Rails.env.development?
  end

  # API v1 Routes (Vue 3 H5 frontend)
  namespace :api do
    namespace :v1 do
      namespace :weixin do
        resources :shops, only: [:index, :show] do
          resources :branches, only: [] do
            resources :products, only: [:index, :show]
            resources :categories, only: [:index]
            resources :orders, only: [:index, :show, :create]
            resources :guest_queues, only: [:index, :show, :create]
            resources :vip_infos, only: [:index, :show]
          end
        end
      end
    end
  end
end
