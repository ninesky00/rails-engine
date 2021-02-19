Rails.application.routes.draw do
  namespace :api do 
    namespace :v1 do 
      resources :merchants do 
        get 'find', on: :collection
        get 'most_items', on: :collection
      end

      scope module: 'merchants', path: 'merchants/:id', as: 'merchants' do 
        resources :items, only: [:index]
      end

      resources :items do 
        get 'find_all', on: :collection
      end

      scope module: 'items', path: 'items/:id', as: 'items' do 
        resource :merchant, only: [:show]
      end

      get 'revenue/merchants', to: 'revenue#merchants'
      get 'revenue', to: 'revenue#revenue_period'
      scope module: 'revenue', path: 'revenue' do 
        resources :merchants, only: [:show]
      end
    end
  end
end
