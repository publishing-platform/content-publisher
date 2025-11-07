class ApplicationController < ActionController::Base
  include PublishingPlatform::SSO::ControllerMethods
  include EditionAssertions

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  rescue_from EditionAssertions::StateError do |e|
    Rails.logger.warn(e.message)
    redirect_to document_path(e.edition.document)
  end
end
