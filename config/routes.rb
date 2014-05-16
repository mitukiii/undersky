Undersky::Application.routes.draw do
  get "users/:name"          => redirect("/%{name}"),        constraints: {name: /[\w\-\.]+/}
  get "users/search"         => redirect("/search")
  get "users/search/:name"   => redirect("/search/%{name}"), constraints: {name: /[\w\-\.]+/}
  get "tags/search"          => redirect("/search")
  get "tags/search/:name"    => redirect("/search/%{name}"), constraints: {name: /[\w\-\.]+/}
  get "tags/recent/:name"    => redirect("/tags/%{name}")

  root to: "media#popular", as: :index

  get "about" => "about#index", as: :about

  controller :authorize do
    get "authorize",    as: :authorize
    get "access_token", as: :access_token
    get "logout",       as: :logout
  end

  get "search(/:name)" => "search#search", as: :search

  get "tags/:name(/max_id/:max_id)" => "tags#recent", as: :tags

  get "media/search"                  => "media#search",    as: :media_search
  get "location/search"               => "location#search", as: :location_search
  get "location/nearby"               => "location#nearby", as: :nearby
  get "location/:id(/max_id/:max_id)" => "location#recent", as: :location

  get "feed(/max_id/:max_id)"            => "users#feed",   as: :feed
  get "liked(/max_like_id/:max_like_id)" => "users#liked",  as: :liked
  get "self"                             => "users#self",   as: :profile
  get ":id(/max_id/:max_id)"             => "users#recent", as: :recent, constraints: {id: /[\w\-\.]+/}

  get ":id/follows(/cursor/:cursor)"     => "relationships#follows",     as: :follows,     constraints: {id: /[\w\-\.]+/}
  get ":id/followed_by(/cursor/:cursor)" => "relationships#followed_by", as: :followed_by, constraints: {id: /[\w\-\.]+/}

  post   ":id/follow" => "relationships#follow",   as: :follow,   constraints: {id: /[\w\-\.]+/}
  delete ":id/follow" => "relationships#unfollow", as: :unfollow, constraints: {id: /[\w\-\.]+/}

  get    "media/:id/likes" => "likes#likes",  as: :likes
  post   "media/:id/likes" => "likes#like",   as: :like
  delete "media/:id/likes" => "likes#unlike", as: :unlike

  get    "media/:id/comments"             => "comments#comments",       as: :comments
  post   "media/:id/comments"             => "comments#create_comment", as: :create_comment
  delete "media/:id/comments/:comment_id" => "comments#delete_comment", as: :delete_comment

  match "*a" => "error#not_found", as: :not_found

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
