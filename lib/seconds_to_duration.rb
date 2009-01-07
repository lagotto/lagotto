module SecondsToDuration
  def self.convert(seconds)
    return seconds if (ActiveSupport::Duration === seconds)
    return (seconds / 1.day).days if (seconds % 1.day == 0)
    return (seconds / 1.hour).hours if (seconds % 1.hour == 0)
    return (seconds / 1.minute).minutes if (seconds % 1.minute == 0)
    seconds.seconds
  end
end
