require 'spec_helper'
require 'stringio'

module Tork
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

      context "calling forward on the last line" do
        before { reader.forward.forward }

        it "should raise an EOF error" do
          expect { reader.forward }.to raise_error EOFError
        end
      end

    end

    context "with an empty stream" do
      let(:stream) { StringIO.new "" }

      it "should raise an EOF error" do
        expect { LogReader.new(stream) }.to raise_error EOFError
      end
    end
  end
end
