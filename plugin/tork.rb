
module TorkLog
  module Error; end
  class ParserError < StandardError; end

  class Parser
    attr_reader :errors

    def initialize(file)
      @file = file
      self.errors = []
    end

    def parse
      parse_log
      self
    rescue Exception => e
      e.extend Error
      raise e
    ensure
      @file.close
    end

  protected
    attr_writer :errors

    def parse_log
      while line = @file.gets
        matcher = LineMatcher.new line
        if matcher.ruby_error?
          parse_ruby_error line
          if errors.empty?
            raise ParserError, "Failed to read error from log file"
          end
          break
        elsif matcher.test_error_or_failure?
          lines = [line]
          while new_line = @file.gets
            new_matcher = LineMatcher.new(new_line)
            if new_matcher.test_error_or_failure? || new_matcher.end_of_errors?
              @file.seek(-new_line.length, IO::SEEK_CUR)
              break
            end
            lines << new_line
          end
          parse_error_or_failure(lines)

        end
      end
    end

    def parse_ruby_error(line)
      matches = line.split(':')
      if matches.length >= 6
        matches.shift(3)
        self.errors << TestError.new(matches.shift.strip,
                                     matches.shift.strip,
                                     matches.join(':').strip,
                                     'E')
      end
    end

    def parse_error_or_failure(lines)
    end
  end

  TestError = Struct.new(:filename, :lnum, :text, :type, :error) do
    def to_s
      "{'filename':'#{filename}','lnum':'#{lnum}','text':'#{text}','type':'#{type}'}"
    end
  end

  class LineMatcher
    PATTERNS = {
      'ruby_error'            => /^[^:]+:[0-9]+:in/,
      'test_error_or_failure' => /^\s\s[0-9]+\)/,
      'test_summary'          => /^([0-9]+\s[a-z]+,)+/,
      'finished_line'         => /^Finished/
    }

    def initialize(line)
      self.line = line
    end

    PATTERNS.each do |name, reg|
      define_method("#{name}?") { !(line =~ PATTERNS[name]).nil? }
      define_method("#{name}")  { PATTERNS[name].match(line) }
    end

    def end_of_errors?
      test_summary? || finished_line?
    end

  protected
    attr_accessor :line
  end
end

def tork_parse_log(log_filename, allow_debug = False)
  parser = TorkLog::Parser.new File.open(log_filename)
  parser.parse
  errors = parser.errors.map(&:to_s)
  error_string = "[#{errors.join(',')}]"
  VIM.command("call setqflist(#{error_string})")
  VIM.command('copen')
end
