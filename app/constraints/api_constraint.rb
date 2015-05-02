class ApiConstraint
  attr_reader :version

  def initialize(options)
    @version = options.fetch(:version)
    @default = options.fetch(:default)
  end

  def matches?(request)
    @default || request.headers.fetch(:accept).include?("version=#{version}")
  end
end
