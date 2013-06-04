require 'spec_helper'

module Quickfix
  describe Populator do
    let(:api) { double('API') }
    before { api.stub(:buffer_from_file) }
    subject { Populator.new api }

    context "calling exclude with a file" do
      let(:file) { 'path/to/file.rb' }
      it "should get the buffer number from the file" do
        api.should_receive(:buffer_from_file).with(file).and_return(3)
        subject.exclude file
      end
    end

    context "populating a quickfix list with an error" do
      let(:error) { {filename: 'test/file.rb', text: 'The error'} }

      before do
        api.should_receive(:get)
      end

      it "should set the quickfix list" do
        api.should_receive(:set).with([error])
        subject.populate [error]
      end
    end

    context "populating an already populated quickfix list" do
      let(:error) { {filename: 'test/file.rb', text: 'The error'} }
      let(:existing) { [{'filename' => 'another/file.rb', 'text' => 'Another error', 'type' => 'E'}] }

      before do
        api.should_receive(:get).and_return(existing)
      end

      it "should set the quickfix list" do
        errors = existing + [error]
        api.should_receive(:set).with(errors)
        subject.populate [error]
      end
    end

    context "populating an already populated quickfix list with errors from the same file" do
      let(:error) { {filename: 'test/file.rb', text: 'The error'} }
      let(:existing) { [{'filename' => 'test/file.rb', 'bufnr' => '3', 'text' => 'Another error', 'type' => 'E'}] }

      before do
        api.should_receive(:buffer_from_file).and_return('3')
        api.should_receive(:get).and_return(existing)
      end

      it "should set the quickfix list" do
        api.should_receive(:set).with([error])
        subject.populate [error]
      end
    end
  end
end
