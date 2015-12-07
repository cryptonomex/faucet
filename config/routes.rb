Rails.application.routes.draw do

    root 'wallet#index'
    get '/refscoreboard', to: 'welcome#refscoreboard'

    resources :widgets do
        get 'w'
        get 'action'
        #get 'get_current_user'
    end

    namespace :api do
        match '*path' => 'base#option', via: [:options]
        namespace :v1 do
            # resources :referral_codes do
            #     get 'claim'
            # end
            resources :accounts do
                get 'status'
            end
        end
    end

    match '*path', via: :all, to: 'welcome#error_404'

end
