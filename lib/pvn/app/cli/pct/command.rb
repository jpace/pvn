#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN; module App; end; end

module PVN::App::Pct
  class Command
    include Loggable

    def initialize args
      clargs = PVN::App::Pct::CmdLineArgs.new args
      info "clargs: #{clargs}"

      elmt = PVN::IO::Element.new :local => clargs.path || '.'
      info "elmt: #{elmt}".red

      stats = { :modified => 0, :added => 0, :deleted => 0 }

      if elmt.directory?
        info "elmt.directory?: #{elmt.directory?}"

        # $$$ todo: recurse even when local has been removed (this is the
        # awaited "pvn find").
        
        changed = Array.new
        elmt.local.find do |fd|
          info "fd: #{fd}; #{fd.class}"
          Find.prune if fd.rootname.to_s == '.svn'
          if fd.file?
            subelmt = PVN::IO::Element.new :local => fd.to_s
            info "subelmt: #{subelmt}"
            status = subelmt.status
            info "status: #{status}".red
          end
        end

        # info "changed: #{changed}"
      elsif elmt.file?
        info "elmt.local: #{elmt.local}".cyan

        status = elmt.status
        info "status: #{status}"

        case status
        when "added"
          info "elmt: #{elmt}".green
        when "modified"
          info "elmt: #{elmt}".yellow
        when "deleted"
          info "elmt: #{elmt}".red
        else
          info "elmt: #{elmt}".cyan
        end
      end
    end
  end
end
