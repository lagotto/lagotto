# adapted from https://github.com/mperham/sidekiq/wiki/Monitoring

require "jwt"

class AuthConstraint
  def self.admin?(request)
    if ENV['JWT_HOST'].present?
      cookie = request.cookie_jar['jwt']
      return false unless cookie.present?

      user = JwtUser.new((JWT.decode cookie, ENV['JWT_SECRET_KEY']).first)
    end

    user.is_admin_or_staff?
  end
end
