if defined?(Footnotes) && (Rails.env.development? || Rails.env.production?)
  Footnotes.run! # first of all

  # ... other init code
end
