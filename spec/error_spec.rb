require 'spec_helper'

module TorkLog
  describe Error do

    shared_examples "an error" do
      let(:error) { Error.new filename, lnum, text, type }

      subject { error }

      its(:filename) { should == filename }
      its(:lnum)     { should == lnum }
      its(:text)     { should == text }
      its(:type)     { should == type }
    end

    context "with some sample data" do
      let(:filename) { '/path/to/file.rb' }
      let(:lnum)     { 23 }
      let(:text)     { 'this is an error message' }
      let(:type)     { 'F' }

      it_behaves_like "an error"
    end

    context "with some alternative sample data" do
      let(:filename) { 'path/to/another/file.rb' }
      let(:lnum)     { 47 }
      let(:text)     { 'A totally different error message' }
      let(:type)     { 'E' }

      it_behaves_like "an error"
    end
  end
end
