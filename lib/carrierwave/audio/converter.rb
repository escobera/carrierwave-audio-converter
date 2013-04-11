require 'carrierwave'
require 'carrierwave/audio/converter/version'
require 'carrierwave/audio/converter/mp3_converter'

module CarrierWave
  module Audio
    module Converter
      extend ActiveSupport::Concern

      module ClassMethods

        def mp3 options = {}
          process mp3: options
        end

      end

      def mp3 opts = {}
        cache_stored_file! if !cached?

        @options = CarrierWave::Audio::Converter::Mp3ConverterOptions.new(opts)

        tmp_path = File.join( File.dirname(current_path), "tmpfile.mp3" )
        converter = Mp3Converter.new(current_path, tmp_path)
        converter.run(@options)
        File.rename tmp_path, current_path
      end

    end
  end
end
