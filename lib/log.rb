module Log

  def log_error(msg)
    RAILS_DEFAULT_LOGGER.error(getTime() + " - ERROR: #{msg}: #{$!}")
    $!.backtrace.map {|line| RAILS_DEFAULT_LOGGER.error "   #{line.sub(RAILS_ROOT, '')}" }
  end
  
  def log_info(msg)
    RAILS_DEFAULT_LOGGER.info(getTime() + " - INFO: #{msg}")
    #output to STDOUT as well
    puts(msg)
  end
  
  def getTime()
    Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end 
end