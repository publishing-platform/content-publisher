Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }

  root to: redirect("/documents")

  resources :documents, only: %i[index new create]  
end
