
module Tork
  module Error; end
  class ParserError < StandardError; end

  class QuickfixPopulator
    def initialize(errors)
      error_strings = errors.map(&:to_s)
      @error_string = "[#{error_strings.join(',')}]"
    end

    def populate
      VIM.command("call setqflist(#{@error_string})")
      self
    end

    def open
      VIM.command('copen')
      self
    end
  end

  class QuickfixError
    def initialize(test_error)
      @e = test_error
    end

    def to_s
      pairs = []
      pairs << quote_pair('filename', @e.filename)
      pairs << quote_pair('lnum', @e.lnum)
      pairs << quote_pair('text', @e.clean_text)
      pairs << quote_pair('type', @e.type)
      "{#{pairs.join(",")}}"
    end

  protected
    def quote_pair(name, value)
      "'#{name}':'#{quote value}'"
    end

    def quote(string)
      string.to_s.gsub("'","\'")
    end
  end

  class TestError < Struct.new(:filename, :lnum, :text, :type)
    def clean_text
      text.strip
    end
  end

  class LogReader
    attr_reader :line

    def initialize(stream)
      @stream = stream
      @line = stream.readline
    end

    def forward
      self.line = stream.readline
      self
    end


    def matcher
      @matcher ||= LineMatcher.new(line)
    end

  protected
    attr_reader :stream
    attr_writer :line

    def line=(line)
      @line = line
      @matcher = nil
    end
  end

  class Parser
    attr_reader :errors

    def initialize(stream)
      @reader = LogReader.new stream
      self.errors = []
    end

    def parse
      parse_log
      self
    rescue EOFError
      # noop
      self
    rescue Exception => e
      # Tag all exceptions with Torkify::Error
      e.extend Error
      raise e
    end

  protected
    attr_writer :errors
    attr_reader :reader

    def parse_log
      loop do
        if reader.matcher.ruby_error?
          parse_ruby_error
          if errors.empty?
            raise ParserError, "Failed to read error from log file"
          end
          break
        elsif tork_line_match = reader.matcher.tork_load_line
          @file_fallback = tork_line_match[1].strip + ".rb"
        elsif reader.matcher.test_error_or_failure?
          parse_errors_or_failures
        end
        reader.forward
      end
    end

    def parse_ruby_error
      line = reader.line
      if tork_match = reader.matcher.tork_error_line
        line.slice! tork_match[0]
      end
      matches = line.split(':')
      if matches.length >= 3
        self.errors << TestError.new(matches.shift.strip,
                                     matches.shift.strip,
                                     matches.join(':').strip,
                                     'E')
      end
    end

    def parse_errors_or_failures
      until reader.matcher.end_of_errors?
        if reader.matcher.test_error_or_failure?
          error = TestError.new(@file_fallback, '0', '', 'E')
          self.errors << error
        end

        matches = reader.matcher.error_description
        error.text << reader.line

        if matches
          matches = matches.to_a
          matches.shift
          error.filename = matches.shift.strip
          error.lnum = matches.shift.strip
        end
        reader.forward
      end
    end

  end

  class LineMatcher
    PATTERNS = {
      'tork_load_line'        => /^Loaded suite tork[^\s]+\s(.+)/,
      'error_description'     => /^[\s#]*([^:]+):([0-9]+):in/,
      'tork_error_line'       => /^.+tork\/master\.rb:[0-9]+:in [^:]+:\s/,
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

    alias :ruby_error :error_description
    alias :ruby_error? :error_description?

  protected
    attr_accessor :line
  end
end

def tork_parse_log(log_filename, allow_debug = False)
  f = File.open(log_filename)
  parser = Tork::Parser.new f
  parser.parse
  errors = parser.errors.map { |e| QuickfixError.new(e) }
  quickfix = QuickfixPopulator.new errors
  quickfix.populate.open
rescue Tork::Error => e
  VIM.command("echoerr \"#{e}\"")
ensure
  f.close
end
