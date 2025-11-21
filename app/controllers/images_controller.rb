class ImagesController < ApplicationController
  def index
    @edition = Edition.find_current(document_id: params[:document_id])
    assert_edition_state(@edition, &:editable?)
  end

  def create
    result = Images::CreateInteractor.call(params:, user: current_user)
    edition, image_revision, issues = result.to_h.values_at(:edition,
                                                            :image_revision,
                                                            :issues)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :index,
             assigns: { edition: },
             status: :unprocessable_entity
    else
      redirect_to crop_image_path(params[:document_id],
                                  image_revision.image_id,
                                  wizard: "upload")
    end
  end

  def crop
    @edition = Edition.find_current(document_id: params[:document_id])
    assert_edition_state(@edition, &:editable?)
    @image_revision = @edition.image_revisions.find_by!(image_id: params[:image_id])
  end

  def update_crop
    result = Images::UpdateCropInteractor.call(params:, user: current_user)
    image_revision = result.image_revision

    if params[:wizard] == "upload"
      redirect_to edit_image_path(params[:document_id],
                                  image_revision.image_id,
                                  wizard: params[:wizard])
    else
      redirect_to images_path(params[:document_id])
    end
  end
end
