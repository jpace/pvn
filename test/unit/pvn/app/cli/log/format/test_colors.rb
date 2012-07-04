#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/entries'
require 'svnx/log/xml/xmllog'
require 'svnx/log/tc'
require 'pvn/io/element'

module PVN
  module App
    module CLI
      module Log
        module Format
          class LogFormatter
            include Loggable
            
            def show logentries
              logentries.each do |entry|
                info "entry.revision: #{entry.revision}"
                info "entry.author  : #{entry.author}"
                info "entry.date    : #{entry.date}"
                info "entry.message : #{entry.message}"
                entry.paths.each do |path|
                  info "    path.kind  : #{path.kind}"
                  info "    path.action: #{path.action}"
                  info "    path.name  : #{path.name}"
                end
              end
            end
          end

          class ColorsTestCase < PVN::Log::TestCase
      
            def test_default_colors
              dir = PVN::IOxxx::Element.new :local => '/Programs/wiquery/trunk'
              
              dirlog = dir.log SVNx::LogCommandArgs.new(:limit => 5, :verbose => true)
              # info "dirlog: #{dirlog}".yellow
              dirlog.entries.each do |entry|
                # info "entry: #{entry}".blue
              end

              fmt = LogFormatter.new
              fmt.show dirlog.entries
            end
          end
        end
      end
    end
  end
end
