require 'spec_helper'

module Quickfix
  describe Stringifier do
    let(:stringifier) { Stringifier.new }
    context "with a test error" do
      let(:error) { Tork::TestError.new('filename.rb', 0, 'The text', 'E') }
      subject { stringifier.convert error }

      it { should == "{\"filename\":\"filename.rb\",\"lnum\":\"0\",\"text\":\"The text\",\"type\":\"E\"}" }
    end

    context "with an error with quotes" do
      let(:error) { Tork::TestError.new('path/to/file.rb', 17, "Text with 'quotes'", 'F') }
      subject { stringifier.convert error }

      it { should == '{"filename":"path/to/file.rb","lnum":"17","text":"Text with \\\'quotes\\\'","type":"F"}' }
    end

    context "with an error with double quotes" do
      let(:error) { Tork::TestError.new('path/to/file.rb', 17, 'Text with "quotes"', 'F') }
      subject { stringifier.convert error }

      it { should == '{"filename":"path/to/file.rb","lnum":"17","text":"Text with \\"quotes\\"","type":"F"}' }
    end

    context "with an error with pre-quoted quotes" do
      let(:error) { Tork::TestError.new('path/to/file.rb', 17, 'Text with \"quotes\"', 'F') }
      subject { stringifier.convert error }

      it { should == '{"filename":"path/to/file.rb","lnum":"17","text":"Text with \\\\\\"quotes\\\\\\"","type":"F"}' }
    end
  end
end
