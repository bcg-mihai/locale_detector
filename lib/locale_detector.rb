require "locale_detector/action"
require "locale_detector/version"

# Make it a Railtie
module LocaleDetector
  require 'locale_detector/railtie' if defined?(Rails)
end
