require 'spec_helper'

def open_test_log_file(name)
  root = File.expand_path(File.dirname(__FILE__))
  File.open "#{root}/logs/#{name}"
end

module TorkLog
  describe "parsing" do
    shared_examples "an error" do
      it             { should be_a TestError }
      its(:text)     { should == expected_text }
      its(:filename) { should == expected_filename }
      its(:lnum)     { should == expected_lnum }
      its(:type)     { should == expected_type }
    end

    shared_examples "an error list with one error" do
      subject { errors }

      it { should be_an Array }
      its(:length) { should == 1 }
    end

    context "a ruby error log" do
      let(:log) { open_test_log_file 'ruby_error_1.log' }
      let(:errors) { Parser.new(log).parse.errors }

      context "the error list" do
        it_behaves_like "an error list with one error"
      end

      context "the error" do
        let(:expected_text) { 'syntax error, unexpected $end, expecting keyword_end (SyntaxError)' }
        let(:expected_filename) { 'spec/integration_spec.rb' }
        let(:expected_lnum) { '6' }
        let(:expected_type) { 'E' }

        subject { errors.first }

        it_behaves_like "an error"
      end
    end

    context "a different ruby error log" do
      let(:log) { open_test_log_file 'ruby_error_2.log' }
      let(:errors) { Parser.new(log).parse.errors }

      context "the error list" do
        it_behaves_like "an error list with one error"
      end

      context "the error" do
        let(:expected_text) { 'syntax error, unexpected keyword_end, expecting \'}\' (SyntaxError)' }
        let(:expected_filename) { 'spec/error_spec.rb' }
        let(:expected_lnum) { '15' }
        let(:expected_type) { 'E' }

        subject { errors.first }

        it_behaves_like "an error"
      end
    end

    context "yet another ruby error log" do
      let(:log) { open_test_log_file 'ruby_error_3.log' }
      let(:errors) { Parser.new(log).parse.errors }

      context "the error list" do
        it_behaves_like "an error list with one error"
      end

      context "the error" do
        let(:expected_text) { 'uninitialized constant TorkLog::Stream (NameError)' }
        let(:expected_filename) { 'spec/stream_spec.rb' }
        let(:expected_lnum) { '4' }
        let(:expected_type) { 'E' }

        subject { errors.first }

        it_behaves_like "an error"
      end
    end

    context "an invalid ruby error" do
      let(:log) { open_test_log_file 'invalid_ruby_error_1.log' }
      let(:parser) { Parser.new(log) }

      it "raises a parse error" do
        expect { parser.parse }.to raise_error ParserError
      end
    end

    context "a test::unit error" do
      let(:log) { open_test_log_file 'test_unit_error_1.log' }
      let(:errors) { Parser.new(log).parse.errors }

      context "the error list" do
        it_behaves_like "an error list with one error"
      end

      context "the error" do
        let(:expected_text) do <<ERR.strip
1) Error:
test: a user should redirect to admin login when visiting admin subdomain. (UserFlowsTest):
NameError: undefined local variable or method `root_pathh' for #<UserFlowsTest:0x000000036f2388>
    test/integration/user_flows_test.rb:8:in `block (2 levels) in <class:UserFlowsTest>'
ERR
        end
        let(:expected_filename) { 'test/integration/user_flows_test.rb' }
        let(:expected_lnum) { '8' }
        let(:expected_type) { 'E' }
        subject { errors.first }

        it_behaves_like "an error"
      end
    end

    context "a test::unit failure" do
      let(:log) { open_test_log_file 'test_unit_failure_1.log' }
      let(:errors) { Parser.new(log).parse.errors }

      context "the error list" do
        it_behaves_like "an error list with one error"
      end

      context "the error" do
        let(:expected_text) do <<ERR.strip
1) Failure:
test: Address should have many companie. (AddressTest)
    []:
Expected Address to have a has_many association called companie (no association called companie)
ERR
        end
        let(:expected_filename) { 'test/unit/address_test.rb' }
        let(:expected_lnum) { '0' }
        let(:expected_type) { 'E' }
        subject { errors.first }

        it_behaves_like "an error"
      end
    end


    context "an rspec error" do
      let(:log) { open_test_log_file 'rspec_failure_1.log' }
      let(:errors) { Parser.new(log).parse.errors }

      context "the error list" do
        it_behaves_like "an error list with one error"
      end

      context "the error" do
        let(:expected_text) do
'1) parsing a test::unit error the error behaves like an error text 
     Failure/Error: Unable to find matching line from backtrace
       expected: "1) Error:\ntest: a user should redirect to admin login when visiting admin subdomain. (UserFlowsTest):\nNameError: undefined local variable or method `root_pathh\' for #<UserFlowsTest:0x000000036f2388>\n    test/integration/user_flows_test.rb:8:in `block (2 levels) in <class:UserFlowsTest>\'\n"
            got: "1) Error:\ntest: a user should redirect to admin login when visiting admin subdomain. (UserFlowsTest):\nNameError: undefined local variable or method `root_pathh\' for #<UserFlowsTest:0x000000036f2388>\n    test/integration/user_flows_test.rb:8:in `block (2 levels) in <class:UserFlowsTest>\'" (using ==)
       Diff:
     Shared Example Group: "an error" called from spec/integration_spec.rb:95
     # spec/integration_spec.rb:12:in `block (3 levels) in <module:TorkLog>\''
        end
        let(:expected_filename) { 'spec/integration_spec.rb' }
        let(:expected_lnum) { '12' }
        let(:expected_type) { 'E' }
        subject { errors.first }

        it_behaves_like "an error"
      end
    end

    context "an rspec log with multiple errors" do
      let(:log) { open_test_log_file 'rspec_failure_2.log' }
      let(:errors) { Parser.new(log).parse.errors }

      context "the error list" do
        subject { errors }

        it { should be_an Array }
        its(:length) { should == 6 }
      end

      context "the first error" do
        subject { errors.first }
        let(:expected_text) do <<LIN.strip
1) parsing a test::unit error the error list behaves like an error list with one error 
     Failure/Error: Unable to find matching line from backtrace
       expected #<TorkLog::Parser:0x00000002be8c08 @file=#<File:/home/jon/.vim/bundle/vim-tork/spec/logs/test_unit_error_1.log>, @errors=[]> to be a kind of Array
     Shared Example Group: "an error list with one error" called from spec/integration_spec.rb:80
     # spec/integration_spec.rb:20:in `block (3 levels) in <module:TorkLog>'
LIN
        let(:expected_filename) { 'spec/integration_spec.rb' }
        let(:expected_lnum) { '20' }
        end
      end

      context "the last error" do
        subject { errors.last }
        let(:expected_text) do <<LIN.strip
6) parsing a test::unit error the error behaves like an error type 
     Failure/Error: Unable to find matching line from backtrace
     NoMethodError:
       undefined method `type' for "type":String
     Shared Example Group: "an error" called from spec/integration_spec.rb:94
     # spec/integration_spec.rb:14:in `block (3 levels) in <module:TorkLog>'
LIN
        let(:expected_filename) { 'spec/integration_spec.rb' }
        let(:expected_lnum) { '14' }
        end
      end
    end
  end
end
