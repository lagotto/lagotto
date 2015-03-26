Dir[File.join(Rails.root, 'lib', '*.rb')].each { |f| require f }

include CustomError

ActiveSupport::XmlMini.backend = 'Nokogiri'
