#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/boolean_option'
require 'pvn/app/cli/subcommands/revision/multiple_revisions_option'

module PVN; module App; module CLI; module Log; end; end; end; end

module PVN::App::CLI::Log
  DEFAULT_LIMIT = 5

  class LimitOption < PVN::Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end

    def set_value val
      super val.to_i
    end
  end

  class VerboseOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :verbose, '-v', [ "include the files in the change" ], false
    end
  end

  class FormatOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :format, '-f', "use the custom (colorized) format", true, :negate => [ '-F', %r{^--no-?format} ], :as_cmdline_option => nil
    end
  end

  class HelpOption < PVN::BooleanOption
    def initialize args = Hash.new
      super :help, '-h', "display help", nil
    end
  end

  class BaseOptionSet < PVN::OptionSet
    @@options = Array.new

    attr_reader :paths
    
    class << self
      def has_option name, optcls, optargs = Hash.new
        attr_reader name

        @@options << { :name => name, :class => optcls, :args => optargs }

        define_method name do
          info "name: #{name}".red
          self.instance_eval do
            meth = name
            info "meth: #{meth}".red
            opt = instance_variable_get '@' + name.to_s
            info "opt: #{opt}".red
            val = opt.value
            info "val: #{val}".red
            val
          end
        end
      end
    end

    def initialize
      super

      @@options.each do |option|
        name = option[:name]
        cls  = option[:class]
        args = option[:args]
        opt  = cls.new(*args)
        info "opt    : #{opt}".on_black
        add opt
        instance_variable_set '@' + name.to_s, opt
      end
    end

    def process args
      options_processed = Array.new

      @unprocessed = args
      
      while !@unprocessed.empty?
        processed = false
        options.each do |opt|
          if opt.process @unprocessed
            processed = true
            options_processed << opt
          end
        end

        break unless processed
      end

      options_processed.each do |opt|
        opt.post_process self, @unprocessed
      end

      @paths = @unprocessed
    end
  end

  class OptionSet < BaseOptionSet
    has_option :revision, PVN::MultipleRevisionsRegexpOption, [ :unsets => :limit ]
    has_option :format, FormatOption
    has_option :help, HelpOption
    has_option :limit, LimitOption
    has_option :verbose, PVN::BooleanOption, [ :verbose, '-v', [ "include the files in the change" ], false ]
    
    def process args
      info "optset: #{self}".on_green
      super
      self
    end
  end
end
