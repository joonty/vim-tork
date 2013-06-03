require 'spec_helper'

module VIM
  def command
    ""
  end

  def evaluate
    ""
  end
end

module Tork
  describe QuickfixPopulator do
    let(:error) { QuickfixError.new({filename: 'abc'}) }
    before { VIM.stub(:evaluate) }
    subject { QuickfixPopulator.new [error] }

    context "creating a populator" do
      it "should call to_s on the error" do
        error.should_receive(:to_s).and_return("The error")
        subject.error_string
      end

      it "should open the quickfix list" do
        VIM.should_receive(:command).with("copen")
        subject.open
      end
    end

    context "populating with an error" do
      before do
        error.should_receive(:to_s).and_return("{\"filename\":\"abc\"}")
      end

      subject { QuickfixPopulator.new [error] }

      it "should set the Vim qflist" do
        VIM.should_receive(:command).with("call setqflist([{\"filename\":\"abc\"}])")
        subject.populate
      end
    end

    context "with multiple errors" do
      before do
        error.should_receive(:to_s).twice.and_return("{\"filename\":\"abc\"}")
      end

      subject { QuickfixPopulator.new [error, error] }

      it "should set the Vim qflist" do
        VIM.should_receive(:command).
          with("call setqflist([{\"filename\":\"abc\"},{\"filename\":\"abc\"}])")
        subject.populate
      end
    end

    context "with existing quickfix errors" do
      before do
        error.should_receive(:to_s).twice.and_return("{\"filename\":\"abc\"}")
      end

      before do
        VIM.should_receive(:evaluate).with('getqflist()').and_return([
          {'lnum' => 34, 'bufnr' => 7, 'col' => 0, 'valid' => 1, 'vcol' => 0, 'nr' => 0, 'type' => 'E', 'pattern' => '', 'text' => 'The first text'},
          {'lnum' => 53, 'bufnr' =>  8, 'col' => 0, 'valid' => 1, 'vcol' => 0, 'nr' => 0, 'type' => 'E', 'pattern' => '', 'text' => 'The second text'}
        ])
        VIM.should_receive(:evaluate).with('bufname("7")').and_return('abc')
        VIM.should_receive(:evaluate).with('bufname("8")').and_return('efg')
      end

      subject { QuickfixPopulator.new [error, error] }

      it "should replace the first error" do
        VIM.should_receive(:command).
          with("call setqflist([{\"filename\":\"abc\"},{\"filename\":\"abc\"},{\"lnum\":\"53\",\"bufnr\":\"8\",\"col\":\"0\",\"valid\":\"1\",\"vcol\":\"0\",\"nr\":\"0\",\"type\":\"E\",\"pattern\":\"\",\"text\":\"The second text\"}])")
        subject.populate
      end
    end
  end
end
