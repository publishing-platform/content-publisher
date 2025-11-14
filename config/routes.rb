Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }

  root to: redirect("/documents")

  resources :documents, only: %i[index new create]

  scope "/documents/:document_id" do
    get "" => "documents#show", as: :document
    get "/generate-path" => "documents#generate_path", as: :generate_path

    get "/content" => "content#edit", as: :content
    patch "/content" => "content#update"

    delete "/draft" => "editions#destroy_draft", as: :destroy_draft
    get "/delete-draft" => "editions#confirm_delete_draft", as: :confirm_delete_draft

    get "/publish" => "publish#confirmation", as: :publish_confirmation
    post "/publish" => "publish#publish"
    get "/published" => "publish#published", as: :published

    post "/submit-for-2i" => "review#submit_for_2i", as: :submit_for_2i
    post "/approve" => "review#approve", as: :approve

    get "/tags" => "tags#edit", as: :tags
    patch "/tags" => "tags#update"

    get "/preview" => "preview#show", as: :preview_document
    post "/preview" => "preview#create"

    get "/remove" => "remove#new", as: :remove
    post "/remove" => "remove#create"

    get "/images" => "images#index", as: :images
    post "/images" => "images#create"
    get "/images/:image_id/download" => "images#download", as: :download_image
    get "/images/:image_id/crop" => "images#crop", as: :crop_image
    patch "/images/:image_id/crop" => "images#update_crop"
    get "/images/:image_id/edit" => "images#edit", as: :edit_image
    patch "/images/:image_id/edit" => "images#update"
    delete "/images/:image_id" => "images#destroy", as: :destroy_image
    get "/images/:image_id/delete" => "images#confirm_delete", as: :confirm_delete_image

    post "/lead-image/:image_id" => "lead_image#choose", as: :choose_lead_image
    delete "/lead-image" => "lead_image#remove", as: :remove_lead_image

    post "/editions" => "editions#create", as: :create_edition
  end
end
