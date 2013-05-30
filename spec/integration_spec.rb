require 'spec_helper'

def open_test_log_file(name)
  root = File.expand_path(File.dirname(__FILE__))
  File.open "#{root}/logs/#{name}"
end

module TorkLog
  describe "tork log parsing integration" do
    shared_examples "a ruby error" do
      its(:text)     { should == expected_text }
      its(:filename) { should == expected_filename }
      its(:lnum)     { should == expected_lnum }
      its(:type)     { should == expected_type }
    end

    context "with a ruby error log" do
      let(:log) { open_test_log_file 'ruby_error_1.log' }
      let(:errors) { Parser.new(log).parse.errors }
      after { log.close }

      subject { errors }

      it { should be_an Array }
      its(:length) { should == 1 }

      context "the error" do
        let(:expected_text) { 'syntax error, unexpected $end, expecting keyword_end (SyntaxError)' }
        let(:expected_filename) { 'spec/integration_spec.rb' }
        let(:expected_lnum) { 6 }
        let(:expected_type) { 'E' }

        subject { errors.first }

        it_behaves_like "a ruby error"
      end
    end

    context "with a different ruby error log" do
      let(:log) { open_test_log_file 'ruby_error_2.log' }
      let(:errors) { Parser.new(log).parse.errors }
      after { log.close }

      subject { errors }

      it { should be_an Array }
      its(:length) { should == 1 }

      context "the error" do
        let(:expected_text) { 'syntax error, unexpected keyword_end, expecting \'}\' (SyntaxError)' }
        let(:expected_filename) { 'spec/error_spec.rb' }
        let(:expected_lnum) { 15 }
        let(:expected_type) { 'E' }

        subject { errors.first }

        it_behaves_like "a ruby error"
      end
    end
  end
end
