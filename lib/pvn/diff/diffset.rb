#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/pathname'
require 'pvn/diff/diffcmd'

module PVN::Diff
  class DiffSet
    include Logue::Loggable
    
    attr_reader :display_path
    attr_reader :from_lines
    attr_reader :from_revision
    attr_reader :to_lines
    attr_reader :to_revision
    attr_reader :whitespace

    def initialize display_path, from_lines, from_revision, to_lines, to_revision, whitespace
      @display_path = display_path
      @from_lines = from_lines
      @from_revision = from_revision
      @to_lines = to_lines
      @to_revision = to_revision
      @whitespace = whitespace
    end

    def run_diff
      info "display_path: #{@display_path}".color("fafa33")
      ext = Pathname.new(@display_path).extname
      info "ext: #{ext}".color("fafa11")

      Cmd.new @display_path, @from_revision, @to_revision, @from_lines, @to_lines, @whitespace
    end
  end
end
