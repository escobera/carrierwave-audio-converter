require 'spec_helper'
require 'carrierwave/audio/converter'

describe CarrierWave::Audio::Converter do

  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end

  #class FFMpegThumbnailer; end

  class TestAudioUploader
    include CarrierWave::Audio::Converter
    def cached?; end
    def cache_stored_file!; end
    def model
      @converter ||= Mp3Converter.new
    end
  end

  let(:uploader) { TestAudioUploader.new }

  describe ".mp3" do
    it "processes the model" do
      TestAudioUploader.should_receive(:process).with(mp3: {option: 'something'})
      TestAudioUploader.mp3({option: 'something'})
    end

    it "does not require options" do
      TestAudioUploader.should_receive(:process).with(mp3: {})
      TestAudioUploader.mp3
    end
  end

  describe "#mp3" do
    let(:converter) { mock  }

    before do
      uploader.stub(:current_path).and_return('audio/path/file.mp3')

      CarrierWave::Audio::Converter::Mp3Converter.should_receive(:new).at_most(10).times.and_return(converter)
    end

    context "with no options set" do
      before {  File.should_receive(:rename).with('audio/path/tmpfile.mp3', 'audio/path/file.mp3') }

      it "runs the converter with empty options list" do
        converter.should_receive(:run) do |options|
          expect(options).to be_empty
        end
        uploader.mp3
      end
    end

    context "with custom passed in" do
      before { File.should_receive(:rename).with('audio/path/tmpfile.mp3', 'audio/path/file.mp3') }

      it "takes the provided custom param" do
        converter.should_receive(:run) do |opts|
          opts[:custom].should eq '-s 256'
        end

        uploader.mp3(custom: '-s 256')
      end
    end

  end
end

