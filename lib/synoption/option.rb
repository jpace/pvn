#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class Option
    include Loggable
    
    attr_accessor :name
    attr_accessor :tag
    attr_accessor :options
    attr_accessor :description

    def initialize *args
      if args.class == Hash
        initialize_from_hash args
      else
        name, tag, description, options = *args
        initialize_from_hash :name => name, :tag => tag, :description => description, :options => options
      end
    end

    def takes_value?
      true
    end

    def initialize_from_hash args
      @name = args[:name]
      @tag = args[:tag]
      @description = args[:description]
      @options = args[:options]
      @value = args[:value]

      defval = @options[:default]

      # interpret the type and setter based on the default type
      if defval && defval.class == Fixnum  # no, we're not handling Bignum
        @options[:setter] ||= :next_argument_as_integer
        @options[:type]   ||= :integer
      end

      if defval
        @value = defval
      end
    end

    def has_svn_option?
      @options.include? :as_svn_option && @options[:as_svn_option]
    end

    def to_command_line
      return nil unless value
      
      if @options.include? :as_svn_option
        @options[:as_svn_option]
      else
        [ tag, value ]
      end
    end

    def to_s
      [ @name, @tag, @options ].join(", ")
    end

    def match? arg
      exact_match?(arg) || negative_match?(arg) || regexp_match?(arg)
    end

    def exact_match? arg
      info "arg: #{arg}".yellow
      info "name: #{name}".yellow

      m = arg == tag || arg == '--' + @name.to_s
      info "m: #{m}".yellow
      m
    end

    def negative_match? arg
      arg && @options && @options[:negate] && @options[:negate].detect { |x| arg.index(x) }
    end

    def regexp_match? arg
      @options[:regexp] && @options[:regexp].match(arg)
    end

    def unset
      @value = nil
    end

    def set_value val
      @value = val
    end

    def value
      @value
    end

    def set optset, cmdobj, args
      debug "self: #{self}"
      debug "args: #{args}"

      if setter = @options[:setter]
        info "setter: #{setter}"
        info "setter.to_proc: #{setter.to_proc}"
        # setters are class methods:
        setter_proc = setter.to_proc
        @value = setter_proc.call cmdobj.class, optset, args
      else
        @value = true
      end

      if unsets = @options[:unsets]
        debug "unsets: #{unsets}"
        optset.unset unsets
      end
      true
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end

    def to_doc_tag
      tagline = "#{tag} [--#{name}]"
      if takes_value?
        tagline << " ARG"
      end
      tagline
    end

    # returns an option regexp as a 'cleaner' string
    def re_to_string re
      re.source.gsub(%r{\\d\+?}, 'N').gsub(%r{[\^\?\$\\\(\)]}, '')
    end

    def to_doc_negate
      doc = nil
      options[:negate].each do |neg|
        str = if neg.kind_of? Regexp
                str = re_to_string neg
              else
                str = neg
              end

        if doc
          doc << " [#{str}]"
        else
          doc = str
        end
      end
      doc
    end

    #   -g [--use-merge-history] : use/display additional information from merge
    # 01234567890123456789012345678901234567890123456789012345678901234567890123456789
    # 0         1         2         3         4         5         6         

    def to_doc_line lhs, rhs, sep = ""
      fmt = "  %-24s %1s %s"
      sprintf fmt, lhs, sep, rhs
    end
      
    def to_doc io
      opttag  = tag
      optdesc = description
      
      RIEL::Log.debug "opttag: #{opttag}"
      RIEL::Log.debug "optdesc: #{optdesc}"

      # wrap optdesc?

      description.each_with_index do |descline, idx|
        lhs = idx == 0 ? to_doc_tag :  ""
        io.puts to_doc_line lhs, descline, idx == 0 ? ":" : ""
      end

      if defval = options[:default]
        io.puts to_doc_line "", "  default: #{defval}"
      end

      if re = options[:regexp]
        io.puts to_doc_line re_to_string(re), "same as above", ":"
      end

      if options[:negate]
        lhs = to_doc_negate
        io.puts to_doc_line lhs, "", ""
      end
    end

  end
end
