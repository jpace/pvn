#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

# read a Subversion dump file, modifying its dates from now - 1 hour to target date

earliest = Time.local(2009)
latest = Time.new - 3600

puts "earliest: #{earliest}"
puts "latest  : #{latest}"

interval = latest.to_i - earliest.to_i

puts "interval: #{interval}"

ndates = 3

0.upto(ndates) do |n|
  time = Time.at(earliest + (interval / (1 + n)))
  puts "time    : #{time}"
  # fake microseconds (available in Ruby 1.9, but not in 1.8)
  ms = rand(1000000)
  str = time.strftime "%FT%T." + sprintf("%06d", ms) + "Z"
  puts "str     : #{str}"
end

# svn format:
# 2011-12-25T00:18:34.971497Z
