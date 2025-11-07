class Requirements::Form::RemovalChecker
  include Requirements::Checker

  attr_reader :edition, :redirect_url

  def initialize(edition, redirect_url)
    @edition = edition
    @redirect_url = redirect_url
  end

  def check
    unless validate_redirect(redirect_url)
      issues.create(:redirect_url, :invalid)
    end
  end

private

  def validate_redirect(redirect_url)
    return true if redirect_url.blank?

    regex = /^\/[a-z0-9]+(?:-[a-z0-9]+)*$/
    redirect_url =~ regex
  end
end
