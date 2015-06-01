class User < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  belongs_to :publisher, primary_key: :member_id
  has_and_belongs_to_many :reports

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:cas, :github, :orcid, :persona]

  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true

  scope :query, ->(query) { where("name like ? OR email like ? OR authentication_token like ?", "%#{query}%", "%#{query}%", "%#{query}%") }
  scope :ordered, -> { order("current_sign_in_at DESC") }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create(generate_user(auth))
  end

  # fetch additional user information for cas strategy
  # use Auth Hash Schema https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
  def self.fetch_raw_info(uid)
    return { error: "no uid provided" } if uid.nil?

    url = "#{ENV['CAS_INFO_URL']}/#{uid}"
    profile = User.new.get_result(url) || { error: "no profile returned" }
    return profile if profile[:error]

    { name: profile.fetch("realName", uid),
      email: profile.fetch("email", nil),
      nickname: profile.fetch("displayName", nil),
      first_name: profile.fetch("givenNames", nil),
      last_name: profile.fetch("surname", nil) }
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = conditions.delete(:email)
    where(conditions).where(["lower(email) = :value", { :value => email.strip.downcase }]).first
  end

  def self.per_page
    15
  end

  # Helper method to check for admin user
  def is_admin?
    role == "admin"
  end

  # Helper method to check for admin or staff user
  def is_admin_or_staff?
    ["admin", "staff"].include?(role)
  end

  # Use different cache key for admin or staff user
  def cache_key
    is_admin_or_staff? ? "1" : "2"
  end

  def api_key
    authentication_token
  end

  def email_with_name
    if email && name != email
      "#{name} <#{email}>"
    else
      email
    end
  end

  protected

  # Don't require email or password, as we also use OAuth
  def email_required?
    false
  end

  def password_required?
    false
  end

  def self.generate_user(auth)
    if User.count > 0 || Rails.env.test?
      authentication_token = generate_authentication_token
      role = "user"
    else
      # use admin role and specific token for first user
      authentication_token = ENV['API_KEY']
      role = "admin"
    end

    { email: auth.info.email,
      name: auth.info.name,
      authentication_token: authentication_token,
      role: role }
  end

  private

  def self.generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
