# = LocalizedTimeZoneSelect
#
# View helper for displaying select list with time zones:
#
#     localized_time_zone_select(:user, :time_zone)
#
# You can easily translate time zones in your application like this:
#     <%= I18n.t @user.time_zone, :scope => 'time_zones' %>
#
# Uses the Rails internationalization framework (I18n) for translating the time zones.
#
# Use Rake task <tt>rake import:time_zone_select[locale]</tt> for importing time zones
# from Unicode.org's CLDR repository (http://www.unicode.org/cldr/data/charts/summary/root.html)
#
# Code adapted from +localized_country_select+ plugin
#
module LocalizedTimeZoneSelect
  class << self
    # Returns array with time zones and localized time zones (according to <tt>I18n.locale</tt>)
    # for <tt><option></tt> tags
    def localized_time_zones_array(options = {})
      # TODO: implement the option logic (sorting, formatting)
        # sort_by = options.delete(:sort_by) || :offset # name | offset | geo (ActiveSupport::TimeZone::MAPPING)
        # format  = options.delete(:format) || :plain   # plain (timezone name as rails knows it => translated) | geo (using tzinfo regions) | compact (group timezone names on location)
      # For now it displays the timezones as rails identifies them (see ActiveSupport::TimeZone::MAPPING) sorted by gmt offset
      ActiveSupport::TimeZone.all.map { |timezone|
        [translate_timezone(timezone), timezone.name] # interpolation can be replaced by a timezone format string in the future
      }
    end
    # Return array with time zones and localized time zones for array of time zones passed as argument
    # == Example
    #   priority_time_zones_array(['Midway Island', 'Mexico city'])
    #   # => [ ['Midway Island', 'Midway Island'], ['Mexico city', 'Mexico city'] ]
    def priority_time_zones_array(time_zones=[])
      translated_time_zones = I18n.translate(:time_zones)
      time_zones.map { |time_zone| [translate_timezone(time_zone), time_zone] }
    end

    def translate_timezone(time_zone, format = nil)
      time_zone = ActiveSupport::TimeZone.new(time_zone.to_s) if !time_zone.is_a?(ActiveSupport::TimeZone)
      "#{I18n.translate(:time_zones)[time_zone.name.to_sym]} (GMT#{time_zone.formatted_offset})" if time_zone && I18n.translate(:time_zones)[time_zone.name.to_sym]
    end
  end
end

module ActionView
  module Helpers

    module FormOptionsHelper

      # Return select and option tags for the given object and method, using +localized_time_zone_options_for_select+
      # to generate the list of option tags. Uses <b>time zone</b> as option +value+.
      # Time zones listed as an array in +priority_time_zones+ argument will be listed first
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      def localized_time_zone_select(object, method, priority_time_zones = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).
          to_localized_time_zone_select_tag(priority_time_zones, options, html_options)
      end

      # Return "named" select and option tags according to given arguments.
      # Use +selected_value+ for setting initial value
      # It behaves likes older object-binded brother +localized_time_zone_select+ otherwise
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      def localized_time_zone_select_tag(name, selected_value = nil, priority_time_zones = nil, options = {}, html_options = {})
        content_tag :select,
                    localized_time_zone_options_for_select(selected_value, priority_time_zones, options),
                    { "name" => name, "id" => name }.update(html_options.stringify_keys)
      end

      # Returns a string of option tags for time zones according to locale.
      # Supply the time zone as +selected+ to have it marked as the selected option tag.
      # Time zones listed as an array in +priority_time_zones+ argument will be listed first
      # The selected item can be an instance of ActiveSupport::TimeZone
      def localized_time_zone_options_for_select(selected = nil, priority_time_zones = nil, options = {})
        time_zone_options = ""
        selected = selected.name if selected.is_a?(ActiveSupport::TimeZone)
        if priority_time_zones
          time_zone_options += "<option value=\"\" disabled=\"disabled\">#{options[:priority_label]}</option>\n" if options[:priority_label]
          time_zone_options += options_for_select(LocalizedTimeZoneSelect::priority_time_zones_array(priority_time_zones), selected)
          time_zone_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end
        return time_zone_options + options_for_select(LocalizedTimeZoneSelect::localized_time_zones_array(options), selected)
      end

    end

    class InstanceTag
      def to_localized_time_zone_select_tag(priority_time_zones, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            localized_time_zone_options_for_select(value, priority_time_zones, options.reject{|k,v| ![:sort_by, :format].include?(k) }),
            options, value
          ), html_options
        )
      end
    end

    class FormBuilder
      def localized_time_zone_select(method, priority_time_zones = nil, options = {}, html_options = {})
        @template.localized_time_zone_select(@object_name, method, priority_time_zones, options.merge(:object => @object), html_options)
      end
    end

  end
end