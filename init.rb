# Require the plugin code
require 'localized_time_zone_select'

# Load locales for time zones from +locale+ directory into Rails
I18n.load_path += Dir[ File.join(File.dirname(__FILE__), 'locale', '*.{rb,yml}') ]