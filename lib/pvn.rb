fdirname = File.dirname(__FILE__)

$:.unshift(fdirname) unless
  $:.include?(fdirname) || $:.include?(File.expand_path(fdirname))

module PVN
  VERSION = '0.0.4'
end
