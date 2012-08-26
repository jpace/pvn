#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/base/doc'

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

      def options opts
        getdoc.options.concat opts
      end

      def optscls
        optmodule = self.to_s.sub %r{::\w+$}, ''
        optcls = optmodule + '::OptionSet'
        optset = instance_eval optcls + '.new'
        getdoc.options.concat optset.options
      end

      def example *ex
        getdoc.examples << ex
      end
    end

    def to_doc io
      doc = self.class.getdoc
      doc.write io
    end
  end

  def show_help
    to_doc $stdout
  end
end
