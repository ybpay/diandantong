Ddt::Application.routes.draw do
  namespace :ddt do
  get 'branch/index'
  end

  namespace :ddt do
  get 'branch/show'
  end

  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  mount Ddt::Core::Engine, :at => '/'

end
