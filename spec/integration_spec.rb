require 'spec_helper'

def open_test_log_file(name)
  root = File.expand_path(File.dirname(__FILE__))
  File.open "#{root}/logs/#{name}"
end

module TorkLog
  describe "parsing" do
    shared_examples "a ruby error" do
      its(:text)     { should == expected_text }
      its(:filename) { should == expected_filename }
      its(:lnum)     { should == expected_lnum }
      its(:type)     { should == expected_type }
    end

    context "a ruby error log" do
      let(:log) { open_test_log_file 'ruby_error_1.log' }
      let(:errors) { Parser.new(log).parse.errors }
      after { log.close }

      context "the error list" do
        subject { errors }

        it { should be_an Array }
        its(:length) { should == 1 }
      end

      context "the error" do
        let(:expected_text) { 'syntax error, unexpected $end, expecting keyword_end (SyntaxError)' }
        let(:expected_filename) { 'spec/integration_spec.rb' }
        let(:expected_lnum) { '6' }
        let(:expected_type) { 'E' }

        subject { errors.first }

        it_behaves_like "a ruby error"
      end
    end

    context "a different ruby error log" do
      let(:log) { open_test_log_file 'ruby_error_2.log' }
      let(:errors) { Parser.new(log).parse.errors }
      after { log.close }

      context "the error list" do
        subject { errors }

        it { should be_an Array }
        its(:length) { should == 1 }
      end

      context "the error" do
        let(:expected_text) { 'syntax error, unexpected keyword_end, expecting \'}\' (SyntaxError)' }
        let(:expected_filename) { 'spec/error_spec.rb' }
        let(:expected_lnum) { '15' }
        let(:expected_type) { 'E' }

        subject { errors.first }

        it_behaves_like "a ruby error"
      end
    end

    context "an invalid ruby error" do
      let(:log) { open_test_log_file 'invalid_ruby_error_1.log' }
      let(:parser) { Parser.new(log) }

      it "raises a parse error" do
        expect { parser.parse }.to raise_error ParserError
      end
    end
  end
end
