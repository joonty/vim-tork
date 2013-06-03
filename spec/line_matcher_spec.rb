require 'spec_helper'

module Tork
  describe LineMatcher do
    shared_examples "a ruby error" do
      let(:matcher) { LineMatcher.new line }

      context "calling ruby_error?" do
        subject { matcher.ruby_error? }

        it { should be_true }
      end
    end

    shared_examples "an error description" do
      let(:matcher) { LineMatcher.new line }

      context "calling error_description?" do
        subject { matcher.error_description? }

        it { should be_true }
      end
    end

    shared_examples "a tork load line" do
      let(:matcher) { LineMatcher.new line }

      context "calling tork_load_line?" do
        subject { matcher.tork_load_line? }

        it { should be_true }
      end
    end

    shared_examples "a tork error line" do
      let(:matcher) { LineMatcher.new line }

      context "calling tork_error_line?" do
        subject { matcher.tork_error_line? }

        it { should be_true }
      end
    end

    shared_examples "the end of errors" do
      let(:matcher) { LineMatcher.new line }

      context "calling end_of_errors?" do
        subject { matcher.end_of_errors? }

        it { should be_true }
      end
    end

    shared_examples "a test error or failure" do
      let(:matcher) { LineMatcher.new line }

      context "calling test_error_or_failure?" do
        subject { matcher.test_error_or_failure? }

        it { should be_true }
      end
    end

    shared_examples "a finished line" do
      let(:matcher) { LineMatcher.new line }

      context "calling finished_line?" do
        subject { matcher.finished_line? }

        it { should be_true }
      end
    end

    shared_examples "a test summary" do
      let(:matcher) { LineMatcher.new line }

      context "calling test_summary?" do
        subject { matcher.test_summary? }

        it { should be_true }
      end
    end

    context "the starting line of a ruby fatal error" do
      let(:line) do <<LIN
test/unit/address_test.rb:3:in `<top (required)>': uninitialized constant Tes (NameError)
LIN
      end

      it_behaves_like "a ruby error"

      context "calling ruby_error" do
        let(:matches) { LineMatcher.new(line).ruby_error }

        context "the whole match" do
          subject { matches[0] }
          it { should == "test/unit/address_test.rb:3:in" }
        end
        context "the file" do
          subject { matches[1] }
          it { should == "test/unit/address_test.rb" }
        end
        context "the line number" do
          subject { matches[2] }
          it { should == "3" }
        end
      end
    end

    context "the starting line of another ruby fatal error" do
      let(:line) do <<LIN
/home/jon/.rvm/gems/ruby-1.9.3-p286/gems/tork-19.3.0/lib/tork/master.rb:62:in `load': spec/line_matcher_spec.rb:79: syntax error, unexpected keyword_end, expecting '}' (SyntaxError)
LIN
      end

      it_behaves_like "a ruby error"
    end

    context "the starting line of an rspec test failure" do
      let(:line) do <<LIN
  1) torklog::linematcher with the starting line of a ruby fatal error calling test_error_or_failure?"
LIN
      end

      it_behaves_like "a test error or failure"
    end

    context "a line of a test::unit test failure" do
      let(:line) { "  15) Failure: " }

      it_behaves_like "a test error or failure"
    end

    context "an rpsec test summary line" do
      let(:line) { "6 examples, 0 failures" }

      it_behaves_like "a test summary"
      it_behaves_like "the end of errors"
    end

    context "a test::unit test summary line" do
      let(:line) do <<LIN
1 tests, 11 assertions, 3 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
LIN
      end

      it_behaves_like "a test summary"
      it_behaves_like "the end of errors"
    end

    context "a test::unit finished line" do
      let(:line) { "Finished in 1.0396772 seconds." }

      it_behaves_like "a finished line"
      it_behaves_like "the end of errors"
    end

    context "the final line of an rspec error" do
      let(:line) do <<LIN
     # spec/integration_spec.rb:20:in `block (3 levels) in <module:TorkLog>'
LIN
      end

      it_behaves_like "an error description"

      context "calling error_description" do
        let(:matches) { LineMatcher.new(line).error_description }

        context "the whole match" do
          subject { matches[0] }
          it { should == "     # spec/integration_spec.rb:20:in" }
        end
        context "the file" do
          subject { matches[1] }
          it { should == "spec/integration_spec.rb" }
        end
        context "the line number" do
          subject { matches[2] }
          it { should == "20" }
        end
      end
    end

    context "the final line of an test::unit error" do
      let(:line) do <<LIN
    test/integration/user_flows_test.rb:8:in `block (2 levels) in <class:UserFlowsTest>'
LIN
      end

      it_behaves_like "an error description"

      context "calling error_description" do
        let(:matches) { LineMatcher.new(line).error_description }

        context "the whole match" do
          subject { matches[0] }
          it { should == "    test/integration/user_flows_test.rb:8:in" }
        end
        context "the file" do
          subject { matches[1] }
          it { should == "test/integration/user_flows_test.rb" }
        end
        context "the line number" do
          subject { matches[2] }
          it { should == "8" }
        end
      end
    end

    context "a tork load line" do
      let(:line) { "Loaded suite tork-worker[1] test/unit/address_test" }

      it_behaves_like "a tork load line"


      context "calling tork_load_line" do
        let(:matches) { LineMatcher.new(line).tork_load_line }

        context "the whole match" do
          subject { matches[0] }
          it { should == "Loaded suite tork-worker[1] test/unit/address_test" }
        end
        context "the file" do
          subject { matches[1] }
          it { should == "test/unit/address_test" }
        end
      end
    end

    context "a tork error line" do
      let(:line) { "/home/jon/.rvm/gems/ruby-1.9.3-p286/gems/tork-19.3.0/lib/tork/master.rb:62:in `load': spec/integration_spec.rb:6: syntax error, unexpected $end, expecting keyword_end (SyntaxError)" }

      it_behaves_like "a tork error line"

      context "calling tork_error_line" do
        let(:matches) { LineMatcher.new(line).tork_error_line }

        context "the whole match" do
          subject { matches[0] }
          it { should == "/home/jon/.rvm/gems/ruby-1.9.3-p286/gems/tork-19.3.0/lib/tork/master.rb:62:in `load': " }
        end
      end
    end
  end
end
