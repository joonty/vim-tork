require 'spec_helper'

module VIM
  def command
  end
end

module TorkLog
  describe QuickfixPopulator do
    let(:error) { double('QuickfixError') }

    context "creating a populator" do
      it "should call to_s on the error" do
        error.should_receive(:to_s).and_return("The error")
        QuickfixPopulator.new [error]
      end
    end

    context "populating with an error" do
      before do
        error.should_receive(:to_s).and_return("{'filename':'abc'}")
      end

      subject { QuickfixPopulator.new [error] }

      it "should set the Vim qflist" do
        VIM.should_receive(:command).with("call setqflist([{'filename':'abc'}])")
        subject.populate
      end

      it "should open the quickfix list" do
        VIM.should_receive(:command).with("copen")
        subject.open
      end
    end

    context "with multiple errors" do
      before do
        error.should_receive(:to_s).twice.and_return("{'filename':'abc'}")
      end

      subject { QuickfixPopulator.new [error, error] }

      it "should set the Vim qflist" do
        VIM.should_receive(:command).
          with("call setqflist([{'filename':'abc'},{'filename':'abc'}])")
        subject.populate
      end
    end
  end
end
