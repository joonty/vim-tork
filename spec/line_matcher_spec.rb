require 'spec_helper'

module TorkLog
  describe LineMatcher do
    shared_examples "a ruby error" do
      let(:matcher) { LineMatcher.new line }

      context "calling ruby_error?" do
        subject { matcher.ruby_error? }

        it { should be_true }
      end

      context "calling test_error_or_failure?" do
        subject { matcher.test_error_or_failure? }

        it { should be_false }
      end

      context "calling test_summary?" do
        subject { matcher.test_summary? }

        it { should be_false }
      end

    end

    shared_examples "a test error or failure" do
      let(:matcher) { LineMatcher.new line }

      context "calling test_error_or_failure?" do
        subject { matcher.test_error_or_failure? }

        it { should be_true }
      end

      context "calling ruby_error?" do
        subject { matcher.ruby_error? }

        it { should be_false }
      end

      context "calling test_summary?" do
        subject { matcher.test_summary? }

        it { should be_false }
      end

    end

    shared_examples "a test summary" do
      let(:matcher) { LineMatcher.new line }

      context "calling test_summary?" do
        subject { matcher.test_summary? }

        it { should be_true }
      end

      context "calling ruby_error?" do
        subject { matcher.ruby_error? }

        it { should be_false }
      end

      context "calling test_error_or_failure?" do
        subject { matcher.test_error_or_failure? }

        it { should be_false }
      end
    end

    context "the starting line of a ruby fatal error" do
      let(:line) {
        "test/unit/address_test.rb:3:in `<top (required)>': uninitialized constant Tes (NameError)"
      }

      it_behaves_like "a ruby error"
    end

    context "the starting line of another ruby fatal error" do
      let(:line) {
          "/home/jon/.rvm/gems/ruby-1.9.3-p286/gems/tork-19.3.0/lib/tork/master.rb:62:in `load': spec/line_matcher_spec.rb:79: syntax error, unexpected keyword_end, expecting '}' (SyntaxError)"
      }

      it_behaves_like "a ruby error"
    end

    context "the starting line of an rspec test failure" do
      let(:line) {
        "  1) torklog::linematcher with the starting line of a ruby fatal error calling test_error_or_failure?"
      }

      it_behaves_like "a test error or failure"
    end

    context "a line of a test::unit test failure" do
      let(:line) {
        "  15) Failure:"
      }

      it_behaves_like "a test error or failure"
    end

    context "an rpsec test summary line" do
      let(:line) { "6 examples, 0 failures" }

      it_behaves_like "a test error or failure"
    end

    context "a test::unit test summary line" do
      let(:line) { "1 tests, 11 assertions, 3 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications" }

      it_behaves_like "a test summary"
    end
  end
end
