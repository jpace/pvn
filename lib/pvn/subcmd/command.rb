require 'pvn/util'
require 'pvn/config'

module PVN
  module Subcommand
    class Command
      def self.executor extor
        @executor = extor
      end
      
      def self.documentor doctor
        @documentor = doctor
      end

      def self.options options
        @options = options
      end
    end
  end
end
