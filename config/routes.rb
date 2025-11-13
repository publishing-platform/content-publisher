Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }

  root to: redirect("/documents")

  resources :documents, only: %i[index new create]

  scope "/documents/:document_id" do
    get "" => "documents#show", as: :document
    
    get "/content" => "content#edit", as: :content
    patch "/content" => "content#update"
  end
end
