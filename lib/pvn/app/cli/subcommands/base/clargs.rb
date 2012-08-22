#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN; module App; end; end

module PVN::App::Base
  class CmdLineArgs
    include Loggable

    class << self
      def has_option name
        define_method name do
          info "name: #{name}"
          self.instance_eval do
            meth = name
            info "meth: #{meth}"
            opt = @optset.send name
            info "opt: #{opt}"
            val = opt.value
            info "val: #{val}"
            val
          end
        end
      end
    end

    def initialize optset, args
      @optset = optset
      process args
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
