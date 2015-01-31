class User < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  belongs_to :publisher, primary_key: :member_id
  has_and_belongs_to_many :reports

  before_save :ensure_authentication_token
  after_create :set_first_user

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:persona, :cas, :github, :orcid]

  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true

  scope :query, ->(query) { where("name like ? OR email like ? OR authentication_token like ?", "%#{query}%", "%#{query}%", "%#{query}%") }
  scope :ordered, -> { order("current_sign_in_at DESC") }

  def self.from_omniauth(auth)
    Rails.logger.debug auth
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
    end
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

  def set_first_user
    # The first user we create has an admin role and uses the configuration
    # API key, unless it is in the test environment
    unless User.count > 1 || Rails.env.test?
      update_attributes(role: "admin", authentication_token: ENV['API_KEY'])
    end
  end

  # Don't require email or password, as we also use OAuth
  def email_required?
    false
  end

  def password_required?
    false
  end

  # Attempt to find a user by it's email. If a record is found, send new
  # password instructions to it. If not user is found, returns a new user
  # with an email not found error.
  def self.send_reset_password_instructions(attributes={})
    recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end

  def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
    (case_insensitive_keys || []).each { |k| attributes[k].try(:downcase!) }

    attributes = attributes.slice(*required_attributes)
    attributes.delete_if { |key, value| value.blank? }

    if attributes.size == required_attributes.size
      record = where(attributes).first
    end

    unless record
      record = new

      required_attributes.each do |key|
        value = attributes[key]
        record.send("#{key}=", value)
        record.errors.add(key, value.present? ? error : :blank)
      end
    end
    record
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
