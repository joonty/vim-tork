require 'spec_helper'
require 'stringio'

module TorkLog
  describe LogReader do
    context "with an IO like data stream" do
      let(:stream) do
        StringIO.new <<-EOD
This is the first line
A second line
The final line
        EOD
      end

      let(:reader) { LogReader.new stream }

      context "calling line" do
        subject { reader.line }

        it { should == "This is the first line\n" }
      end

      context "calling forward" do
        before { reader.forward }
        subject { reader.line }
        it { should == "A second line\n" }
      end

      context "calling matcher" do
        subject { reader.matcher }

        it { should be_a LineMatcher }
      end

    end
  end
end
