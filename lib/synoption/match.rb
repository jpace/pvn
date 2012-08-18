#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'synoption/doc'

module PVN
  class OptionMatch
    include Loggable

    attr_reader :option

    def initialize option
      @option = option
    end

    def match? arg
      raise "not implemented"
    end
  end

  class OptionExactMatch < OptionMatch
    def match? arg
      arg == option.tag || arg == '--' + option.name.to_s
    end
  end

  class OptionNegativeMatch < OptionMatch
    def initialize option, negopt
      super option
      @negopt = negopt
    end

    def match? arg
      arg && @negopt.detect { |x| arg.index(x) }
    end
  end

  class OptionRegexpMatch < OptionMatch
    def initialize option, regexp
      super option
      @regexp = regexp
    end

    def match? arg
      arg and @regexp.match arg
    end
  end
end
