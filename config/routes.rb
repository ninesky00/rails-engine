Rails.application.routes.draw do
  namespace :api do 
    namespace :v1 do 
      resources :merchants do 
        get 'find', on: :collection
      end
      scope module: 'merchants', path: 'merchants/:id', as: 'merchants' do 
        resources :items, only: [:index]
      end
      resources :items
      scope module: 'items', path: 'items/:id', as: 'items' do 
        resource :merchant, only: [:show]
      end
    end
  end
end
