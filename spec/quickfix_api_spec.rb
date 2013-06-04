require 'spec_helper'

module Quickfix
  describe API do
    let(:api) { Quickfix::API.new }

    context "calling get" do

      let(:expected_return) { { a: 1, b: 2, c: 3 } }
      before do
        VIM.should_receive(:evaluate).with('getqflist()').
          and_return(expected_return)
      end

      subject { api.get }

      it { should == expected_return }
    end

    context "calling set with dummy hashes" do
      let(:arg) { [{a: 1, b:2, c: 3}] }

      it "should send the correct vim command" do
        VIM.should_receive(:command).with('call setqflist([{"a":"1","b":"2","c":"3"}])')
        api.set(arg)
      end
    end

    context "calling set with dummy hashes with quotes" do
      let(:arg) { [{a: 'This is a message with "quotes"', b: 'Text', c: 'Text'}] }

      it "should send the correct vim command" do
        VIM.should_receive(:command).with('call setqflist([{"a":"This is a message with \"quotes\"","b":"Text","c":"Text"}])')
        api.set(arg)
      end
    end

    context "calling buffer_from_file with a file name" do
      let(:expected_return) { 19 }
      let(:file) { "path/to/file.rb" }
      before do
        VIM.should_receive(:evaluate).with("bufnr(\"#{file}\")").
          and_return(expected_return)
      end

      subject { api.buffer_from_file file }

      it { should == expected_return }
    end

    context "calling open" do
      it "should call copen on VIM" do
        VIM.should_receive(:command).with('copen')
        api.open
      end
    end
  end
end
