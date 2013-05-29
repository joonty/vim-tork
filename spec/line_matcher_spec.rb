require 'spec_helper'

module TorkLog
  describe LineMatcher do
    context "with the starting line of a ruby fatal error" do

      before do
        @line = <<ERR
test/unit/address_test.rb:3:in `<top (required)>': uninitialized constant Tes (NameError)
ERR
      end

      let(:matcher) { LineMatcher.new @line }

      context "calling ruby_error?" do
        subject { matcher.ruby_error? }

        it { should be_true }
      end

      context "calling test_error_or_failure?" do
        subject { matcher.test_error_or_failure? }

        it { should be_false }
      end
    end

    context "with the starting line of an rspec test failure" do
      before do
        @line = <<ERR
  1) TorkLog::LineMatcher with the starting line of a ruby fatal error calling test_error_or_failure?
ERR
      end

      let(:matcher) { LineMatcher.new @line }

      context "calling test_error_or_failure?" do
        subject { matcher.test_error_or_failure? }

        it { should be_true }
      end

      context "calling ruby_error?" do
        subject { matcher.ruby_error? }

        it { should be_false }
      end
    end
  end
end
