#!/usr/bin/ruby -w
# -*- ruby -*-

require 'date'

module PVN::Log
  # a format for the date.
  class DateFormatter
    DEFAULT_FORMAT = "%y-%m-%d %H:%M:%S"

    def format date
      dt = date.kind_of?(DateTime) ? date : DateTime.parse(date.to_s)
      dt.strftime DEFAULT_FORMAT
    end
  end
end
