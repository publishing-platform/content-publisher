class ApplicationController < ActionController::Base
  include PublishingPlatform::SSO::ControllerMethods
  include EditionAssertions

  helper_method :rendering_context
  layout -> { rendering_context }

  before_action :authenticate_user!

  rescue_from EditionAssertions::StateError do |e|
    Rails.logger.warn(e.message)

    if rendering_context == "modal"
      raise ActionController::BadRequest
    elsif e.edition.first? && e.edition.discarded?
      redirect_to documents_path
    else
      redirect_to document_path(e.edition.document)
    end
  end

  rescue_from EditionAssertions::FeatureError do |e|
    raise ActionController::RoutingError, e.message
  end

  def rendering_context
    request.headers["Content-Publisher-Rendering-Context"] || "application"
  end
end
