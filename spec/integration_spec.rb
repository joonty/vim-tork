require 'spec_helper'

def open_test_log_file(name)
  root = File.expand_path(File.dirname(__FILE__))
  File.open "#{root}/logs/#{name}"
end

module TorkLog
  describe "tork log parsing integration" do

    context "with a ruby error log, the errors" do
      let(:log) { open_test_log_file 'ruby_error_1.log' }
      let(:errors) { Parser.new(log).parse.errors }
      after { log.close }

      subject { errors }

      it { should be_an Array }
      its(:length) { should == 1 }

      context "the error" do
        subject { errors.first }

        its(:text) { should == 'syntax error, unexpected $end, expecting keyword_end (SyntaxError)' }
        its(:filename) { should == 'spec/integration_spec.rb' }
        its(:lnum) { should == 'spec/integration_spec.rb' }
        its(:type) { should == 'E' }
      end
    end
  end
end
