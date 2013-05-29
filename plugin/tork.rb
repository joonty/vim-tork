
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
    end
  end

  class LineMatcher
    RUBY_ERROR_PATTERN = /^.+:[0-9]+:in/
    TEST_ERROR_OR_FAILURE_PATTERN = /^\s\s[0-9]+\)/

    def initialize(line)
      self.line = line
    end

    def ruby_error?
      !(line =~ RUBY_ERROR_PATTERN).nil?
    end

    def test_error_or_failure?
      !(line =~ TEST_ERROR_OR_FAILURE_PATTERN).nil?
    end

  protected
    attr_accessor :line
  end
end

def tork_parse_log(log_filename, allow_debug = False)
  parser = TorkLog::Parser.new File.open(log_filename)
end
