require 'rubygems'

# Rake task for importing time zone names

namespace :import do

  desc "Create localized time zone translations for provided locale."
  task :time_zone_select, :locale do |t, args|

    # Setup variables
    locale = args.locale || nil
    if locale.nil?
      puts "\n[!] Usage: rake import:time_zone_select locale\n\n"
      exit 0
    end

    # ----- Prepare the output format     ------------------------------------------
    output =<<HEAD
{ :#{locale} => {

    :time_zones => {
HEAD
    ActiveSupport::TimeZone.all.each do |time_zone|
      output << "\t\t\t\"#{time_zone.name}\" => \"#{time_zone.name}\",\n"
    end
    output <<<<TAIL
    }

  }
}
TAIL

    # ----- Write the parsed values into file      ---------------------------------
    puts "\n... writing the output"
    filename = File.join(File.dirname(__FILE__), '..', 'locale', "#{locale}.rb")
    filename += '.NEW' if File.exists?(filename) # Append 'NEW' if file exists
    File.open(filename, 'w+') { |f| f << output }
    puts "\n---\nWritten values for the '#{locale}' into file: #{filename}\n"
    # ------------------------------------------------------------------------------
  end

end
