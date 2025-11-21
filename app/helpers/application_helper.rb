module ApplicationHelper
  def strip_scheme_from_url(url)
    url.sub(/^https?:\/\//, "")
  end

  def render_back_link(options)
    render("components/back_link", options)
  end

  def render_markdown(content)
    raw(PublishingPlatformMarkdown::Document.new(content).to_html)
  end

  def name_or_fallback(user)
    user&.name || I18n.t("documents.unknown_user")
  end

  def navigation_items
    return [] unless current_user

    items = []

    items << { text: current_user.name, href: PublishingPlatformLocation.external_url_for("signon") }
    items << { text: "Sign out", href: publishing_platform_sign_out_path }
  end

  def is_current?(link)
    recognized = Rails.application.routes.recognize_path(link)
    recognized[:controller] == params[:controller] &&
      recognized[:action] == params[:action]
  end
end
