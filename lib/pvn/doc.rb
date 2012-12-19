#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/log/loggable'
require 'pvn/documenter'

module PVN
  module Doc
    include RIEL::Loggable

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      [ :subcommands, :description, :usage, :summary, :examples ].each do |name|
        define_method name do |val|
          self.instance_eval do 
            @doc ||= Documenter.new
            meth = (name.to_s + '=').to_sym
            @doc.send meth, val
          end
        end
      end
      
      def to_doc io = $stdout
        self.instance_eval { @doc.to_doc io }
      end
    end
  end
end
