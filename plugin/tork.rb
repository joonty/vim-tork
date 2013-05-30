
module TorkLog
  class Parser
    def initialize(file)
      @file = file
    end

    def parse
      @file.each_line do |line|
        matcher = LineMatcher.new line
        if matcher.ruby_error?
        end
      end
      self
    end

    def errors
    end
  end

  Error = Struct.new(:file, :lnum, :text, :type, :error)

  class LineMatcher
    PATTERNS = {
      :ruby_error            => /^.+:[0-9]+:in/,
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
