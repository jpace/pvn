#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/command/doc'
require 'logue/loggable'

module PVN; module Command; end; end

module PVN::Command
  class Command
    include Logue::Loggable

    @@doc_for_class = Hash.new { |h, k| h[k] = PVN::Command::Documentation.new }
    
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
    
    def to_doc
      doc = self.class.getdoc
      doc.write
    end

    def show_help
      to_doc
    end

    def initialize args
      options = self.class.optset
      options.process args
      
      if options.help
        show_help
      else
        init options
      end
    end

    def init options
      raise "implement this to handle non-help options"
    end
  end
end
