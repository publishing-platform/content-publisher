module AuthenticationHelper
  def login_as(user)
    PublishingPlatform::SSO.test_user = user
    Capybara.reset_sessions!
  end

  def current_user
    PublishingPlatform::SSO.test_user || User.first
  end

  def reset_authentication
    PublishingPlatform::SSO.test_user = nil
    Capybara.reset_sessions!
  end
end
