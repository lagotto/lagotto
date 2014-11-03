module IntegrationSpecHelper
  def login_with_oauth(service = :persona)
    visit "/auth/#{service}"
  end
end
