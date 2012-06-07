#
# ActiveSupport patch
#

class ActiveSupport::BufferedLogger
  def formatter=(formatter)
    @log.formatter = formatter
  end
end

class Formatter

  def call(severity, time, progname, msg)
    "#{time.strftime('%F %T %z')} pid:#{Process.pid} #{severity} #{msg} \n"
  end

end

Rails.logger.formatter = Formatter.new
