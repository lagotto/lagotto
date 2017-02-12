class User
  attr_accessor :name, :uid, :email, :role, :api_key, :orcid, :publisher_id

  def initialize(jwt={})
    @uid = jwt.fetch("uid", nil)
    @name = jwt.fetch("name", nil)
    @email = jwt.fetch("email", nil)
    @role = jwt.fetch("role", nil)
    @api_key = jwt.fetch("api_key", nil)
    @publisher_id = nil
  end

  alias_method :orcid, :uid
  alias_method :id, :uid

  # Helper method to check for admin user
  def is_admin?
    role == "admin"
  end

  # Helper method to check for admin or staff user
  def is_admin_or_staff?
    ["admin", "staff"].include?(role)
  end
end
