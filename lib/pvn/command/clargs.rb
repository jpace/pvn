#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel/log/loggable'

module PVN; module App; end; end

module PVN::App::Base
  class CmdLineArgs
    include RIEL::Loggable

    class << self
      def has_option name
        define_method name do
          info "name: #{name}"
          self.instance_eval do
            meth = name
            info "meth: #{meth}"
            val = @optset.send name
            info "val: #{val}"
            val
          end
        end
      end
    end

    attr_reader :unprocessed

    def initialize optset, args
      @optset = optset
      process args
      @unprocessed = args
    end

    def process args
      options_processed = Array.new
      
      while !args.empty?
        processed = false
        @optset.options.each do |opt|
          if opt.process args
            processed = true
            options_processed << opt
          end
        end

        break unless processed
      end

      options_processed.each do |opt|
        opt.post_process @optset, args
      end
    end
  end
end
