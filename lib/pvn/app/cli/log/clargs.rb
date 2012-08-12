#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision'
require 'pvn/revision/entry'

module PVN
  module App
    module Log
      class CmdLineArgs
        include Loggable

        attr_reader :limit
        attr_reader :revision
        attr_reader :path

        def initialize args
          @limit = nil
          @revision = nil
          @path = '.'

          revargs = Array.new

          while !args.empty?
            arg = args.shift

            case arg
            when "--limit", "-l"
              @limit = args.shift.to_i
            when %r{-r(.*)}
              revval = Regexp.last_match[1]
              if PVN::Revisionxxx::RELATIVE_REVISION_RE.match revval
                revargs << revval
              else
                @revision = revval
              end
            else
              if PVN::Revisionxxx::RELATIVE_REVISION_RE.match(arg)
                revargs << arg
              else
                @path = arg
              end
            end
          end

          if not revargs.empty?
            logforrev = SVNx::LogCommandLine.new @path
            logforrev.execute
            xmllines = logforrev.output

            revargs.each do |revarg|
              reventry = PVN::Revisionxxx::Entry.new :value => revarg, :xmllines => xmllines.join('')
              revval   = reventry.value.to_s

              if @revision
                @revision << ":" << revval
                info "@revision: #{@revision}".bold.yellow
              else
                @revision = revval
                info "@revision: #{@revision}".bold.cyan
              end
            end
          end

          info "@revision: #{@revision}".bold.magenta
        end
      end
    end
  end
end
