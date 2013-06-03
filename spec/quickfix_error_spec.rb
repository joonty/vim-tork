require 'spec_helper'

module TorkLog
  describe QuickfixError do
    context "with a test error" do
      let(:error) { TestError.new('filename.rb', 0, 'The text', 'E') }
      subject { QuickfixError.new error }

      its(:to_s) { should == "{'filename':'filename.rb','lnum':'0','text':'The text','type':'E'}" }
    end

    context "with another test error" do
      let(:error) { TestError.new('path/to/file.rb', 17, "Text with 'quotes'", 'F') }
      subject { QuickfixError.new error }

      its(:to_s) { should == "{'filename':'path/to/file.rb','lnum':'17','text':'Text with \'quotes\'','type':'F'}" }
    end
  end
end
