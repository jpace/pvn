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

      alias_method :init, :new
      alias_method :new_for_help, :new

      def new args
        options = optset
        options.process args

        if options.help
          cmd = new_for_help nil
          cmd.show_help
        else
          init options
        end
      end
    end

    def to_doc io
      doc = self.class.getdoc
      doc.write io
    end

    def show_help
      to_doc $stdout
    end
  end
end
