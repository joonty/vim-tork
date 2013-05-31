
module TorkLog
  module Error; end
  class ParserError < StandardError; end

  TestError = Struct.new(:filename, :lnum, :text, :type, :error) do
    def to_s
      "{'filename':'#{filename}','lnum':'#{lnum}','text':'#{text}','type':'#{type}'}"
    end
  end

  class LogReader
    attr_reader :line

    def initialize(stream)
      @stream = stream
      @line = stream.gets
    end

    def forward
      self.line = stream.gets
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

    def initialize(file)
      @file = file
      self.errors = []
    end

    def parse
      parse_log
      self
    rescue Exception => e
      # Tag all exceptions with Torkify::Error
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
        elsif tork_line_match = matcher.tork_load_line
          @file_fallback = tork_line_match[1].strip + ".rb"
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
      p matches
      if matches.length >= 6
        matches.shift(3)
        self.errors << TestError.new(matches.shift.strip,
                                     matches.shift.strip,
                                     matches.join(':').strip,
                                     'E')
      end
    end

    def parse_error_or_failure(lines)
      text = lines.join.strip
      added_error = false
      lines.each do |line|
        matches = LineMatcher.new(line).error_description
        if matches
          matches = matches.to_a
          matches.shift
          self.errors << TestError.new(matches.shift.strip,
                                       matches.shift.strip,
                                       text, 'E')
          added_error = true
          break
        end
      end
      unless added_error
        self.errors << TestError.new(@file_fallback,
                                     "0", text, 'E')
      end
    end
  end

  class LineMatcher
    PATTERNS = {
      'tork_load_line'        => /^Loaded suite tork[^\s]+\s(.+)/,
      'error_description'     => /^[\s#]*([^:]+):([0-9]+):in/,
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

  class RubyErrorParser
    def initialize()
    end
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
