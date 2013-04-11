require 'spec_helper'
require 'carrierwave/audio/converter'

describe CarrierWave::Audio::Converter::Mp3Converter do

  describe "#run" do
    let(:input_file_path) { '/tmp/file.wav' }
    let(:output_file_path) { '/tmp/file.mp3' }
    let(:binary) { 'lame' }

    let(:converter) { CarrierWave::Audio::Converter::Mp3Converter.new(input_file_path, output_file_path) }

    before do
      CarrierWave::Audio::Converter::Mp3Converter.binary = binary
    end

    it "should run the lame binary" do
      @options = CarrierWave::Audio::Converter::Mp3ConverterOptions.new({})
      command = "#{binary} -i #{input_file_path} -o #{output_file_path}"
      Open3.should_receive(:popen3).with(command)

      converter.run(@options)
    end

    context "with full set of CLI options" do

      it "runs the converter with all corresponding CLI keys" do

        opts = {
          format:     'png',
          size:       '512',
          seek:       '20%',
          quality:    10,
          square:     true,
          strip:      true,
          workaround: true,
          custom:     '-v'
        }

        @options = CarrierWave::Audio::Converter::Mp3ConverterOptions.new opts

        cli = "#{binary} -i #{input_file_path} -o #{output_file_path} -c png -s 512 -t 20% -q 10 -a -f -w -v"
        Open3.should_receive(:popen3).with(cli)

        converter.run @options
      end

    end

    context "given a logger" do
      let(:logger) { mock(:logger) }

      it "should run and log results" do
        @options = CarrierWave::Audio::Converter::Mp3ConverterOptions.new({logger: logger})
        command = "#{binary} -i #{input_file_path} -o #{output_file_path}"
        Open3.should_receive(:popen3).with(command)
        logger.should_receive(:info).with("Running....#{command}")
        logger.should_receive(:error).with("Failure!")

        converter.run @options
      end
    end
  end
end


