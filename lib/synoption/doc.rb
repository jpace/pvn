#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  # documentation for an option.
  class Doc
    include Loggable

    def initialize option
      @option = option
    end

    def to_doc_tag
      tagline = "#{@option.tag} [--#{@option.name}]"
      if @option.takes_value?
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
      @option.negate.each do |neg|
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
      opttag  = @option.tag
      optdesc = @option.description
      
      # wrap optdesc?

      @option.description.each_with_index do |descline, idx|
        lhs = idx == 0 ? to_doc_tag :  ""
        io.puts to_doc_line lhs, descline, idx == 0 ? ":" : ""
      end

      if defval = @option.default
        io.puts to_doc_line "", "  default: #{defval}"
      end

      if re = @option.regexp
        io.puts to_doc_line re_to_string(re), "same as above", ":"
      end

      if @option.negate
        lhs = to_doc_negate
        io.puts to_doc_line lhs, "", ""
      end
    end
  end
end
