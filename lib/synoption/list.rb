#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  class OptionList    
    attr_reader :options
    
    def initialize options = Array.new
      @options = options
    end

    def inspect
      @options.collect { |opt| opt.inspect }.join("\n")
    end

    def find_by_name name
      @options.find { |opt| opt.name == name }
    end

    def has_option? name
      find_by_name name
    end

    def to_command_line
      cmdline = Array.new
      @options.each do |opt|
        if cl = opt.to_command_line
          cmdline.concat cl
        end
      end
      cmdline
    end

    def << option
      @options << option
    end

    def add option
      @options << option
      option
    end
  end
end
