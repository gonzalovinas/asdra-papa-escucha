Rails.application.routes.draw do

  root 'welcome#index'

  get 'welcome/login'
  
  post '/welcome/do_login'
  
  get 'welcome/index'

  get 'welcome/resumen'

  get 'welcome/mensajes_novedades_rss'

  get 'entrevista/alta_nueva_entrevista'

  post 'entrevista/do_alta_nueva_entrevista'

  post 'entrevista/do_buscar_entrevistas'

  get 'entrevista/buscar_entrevistas'

  get 'administracion/mensaje_novedad'

  post 'administracion/do_alta_nuevo_mensaje_novedad'

  get 'administracion/alta_nuevo_padre'

  post 'administracion/do_alta_nuevo_padre'

  get 'administracion/configuracion'

  get 'entrevista/consulta_entrevista'

  get 'administracion/buscar_padres'

  post 'administracion/do_buscar_padres'

  get 'welcome/acerca'

  get 'welcome/acerca_sistema'
  get 'welcome/acerca_marcas'
  get 'welcome/acerca_soporte'

  post 'administracion/eliminar_padres'

  post 'entrevista/eliminar_entrevistas'

  get 'administracion/do_buscar_padres_excel'

  get 'entrevista/do_buscar_entrevistas_excel'

  get 'entrevista/actualizar_entrevista'

  post 'entrevista/do_actualizar_entrevista'

  get 'entrevista/cambiar_estado_entrevistas'

  post 'entrevista/do_cambiar_estados'

  get 'administracion/administrar_estados_entrevistas'

  post 'administracion/do_buscar_estados_entrevistas'

  get 'administracion/alta_nuevo_estado_entrevista'

  post 'administracion/do_alta_nuevo_estado_entrevista'

  post 'administracion/eliminar_estados_entrevistas'

  get 'entrevista/agendar_entrevistas'

  post 'entrevista/do_agendar_entrevistas'

  get 'entrevista/asignar_padres_entrevistas'

  post 'entrevista/do_asignar_padres_entrevistas'

  get 'entrevista/entrevistas_pdf'

  get 'entrevista/alta_nuevo_hermano'

  post 'administracion/do_mantenimiento'
  
  post 'entrevista/notificar'

  get 'administracion/actualizar_padre'

  post 'administracion/do_actualizar_padre'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
