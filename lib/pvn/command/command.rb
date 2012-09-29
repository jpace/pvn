#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/doc'

module PVN; module Subcommands; module Base; end; end; end

module PVN::Subcommands::Base
  class Command
    include Loggable

    @@doc_for_class = Hash.new { |h, k| h[k] = PVN::Subcommands::Documentation.new }
    
    class << self
      def getdoc
        @@doc_for_class[self]
      end

      def subcommands sc
        getdoc.subcommands = sc
      end

      def description desc
        getdoc.description = desc
      end

      def usage usg
        getdoc.usage = usg
      end

      def summary smry
        getdoc.summary = smry
      end

      ### $$$ remove this:
      def options opts
        getdoc.options.concat opts
      end

      def optscls
        getdoc.options.concat optset.options
      end

      def optset
        optmodule = to_s.sub %r{::\w+$}, ''
        optcls = optmodule + '::OptionSet'
        optset = instance_eval optcls + '.new'
      end

      def example *ex
        getdoc.examples << ex
      end

      def matches_subcommand? sc
        getdoc.subcommands.include? sc
      end
    end
    
    def to_doc io
      doc = self.class.getdoc
      doc.write io
    end

    def show_help
      to_doc $stdout
    end

    def initialize args
      options = self.class.optset
      options.process args
      
      if options.help
        cmd.show_help
      else
        init options
      end
    end

    def init options
      raise "implement this to handle non-help options"
    end
  end
end
