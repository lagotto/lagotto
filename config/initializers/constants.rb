# encoding: UTF-8

# Networking constants
DEFAULT_TIMEOUT = 60
NETWORKABLE_EXCEPTIONS = [Faraday::Error::ClientError,
                          Delayed::WorkerTimeout,
                          URI::InvalidURIError,
                          Encoding::UndefinedConversionError,
                          ArgumentError,
                          NoMethodError,
                          TypeError]

# Format used for DOI validation
# The prefix is 10.x where x is 4-5 digits. The suffix can be anything, but can't be left off
DOI_FORMAT = %r(\A10\.\d{4,5}/.+)

# Form interval options
INTERVAL_OPTIONS = [['½ hour', 30.minutes],
                    ['1 hour', 1.hour],
                    ['2 hours', 2.hours],
                    ['3 hours', 3.hours],
                    ['6 hours', 6.hours],
                    ['8 hours', 8.hours],
                    ['12 hours', 12.hours],
                    ['24 hours', 24.hours],
                    ['2 days', 48.hours],
                    ['4 days', 96.hours],
                    ['¼ month', (1.month * 0.25).to_i],
                    ['½ month', (1.month * 0.5).to_i],
                    ['1 month', 1.month],
                    ['3 months', 3.months],
                    ['6 months', 6.months],
                    ['12 months', 12.months]]
