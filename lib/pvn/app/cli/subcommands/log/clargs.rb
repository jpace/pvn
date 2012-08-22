#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/app/cli/subcommands/base/clargs'

module PVN; module App; end; end

module PVN::App::Log
  class CmdLineArgs < PVN::App::Base::CmdLineArgs
    attr_reader :path

    has_option :revision
    has_option :limit
    has_option :verbose
    has_option :format
    has_option :help

    def initialize optset, args
      super
      @path = args[0] || "."
    end
  end
end
