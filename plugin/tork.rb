
module TorkLog
  class Parser
    attr_reader :errors

    def initialize(file)
      @file = file
      self.errors = []
    end

    def parse
      @file.each_line do |line|
        matcher = LineMatcher.new line
        if matcher.ruby_error?
          parse_ruby_error line
          break
        end
      end
      self
    end

  protected
    attr_writer :errors

    def parse_ruby_error(line)
      matches = line.split(':')
      matches.shift(3)
      if matches.length >= 3
        self.errors << TestError.new(matches.shift.strip,
                                     matches.shift.strip,
                                     matches.join(':').strip,
                                     'E')
      end
    end
  end

  TestError = Struct.new(:filename, :lnum, :text, :type, :error)

  class LineMatcher
    PATTERNS = {
      :ruby_error            => /^[^:]+:[0-9]+:in/,
      :test_error_or_failure => /^\s\s[0-9]+\)/,
      :test_summary          => /^([0-9]+\s[a-z]+,)+/
    }

    def initialize(line)
      self.line = line
    end

    def ruby_error?
      !(line =~ PATTERNS[:ruby_error]).nil?
    end

    def test_error_or_failure?
      !(line =~ PATTERNS[:test_error_or_failure]).nil?
    end

    def test_summary?
      !(line =~ PATTERNS[:test_summary]).nil?
    end

  protected
    attr_accessor :line
  end
end

def tork_parse_log(log_filename, allow_debug = False)
  parser = TorkLog::Parser.new File.open(log_filename)
end
