module WritingMethods
  module DFL
    # A `DFL::Head`'s sound data
    module Sound
      # Writes out the sound given the io
      def write(io : IO)
        io.write_bytes(sample_rate.to_u32, IO::ByteFormat::LittleEndian)
        io.write_bytes(samples_num.to_u32, IO::ByteFormat::LittleEndian)
        io.write_bytes(bits_per_sample.to_u16, IO::ByteFormat::LittleEndian)

        samples.each do |sample|
          case bits_per_sample
          when 8
            io.write_bytes(sample.to_u8, IO::ByteFormat::LittleEndian)
          when 16
            io.write_bytes(sample.to_u16, IO::ByteFormat::LittleEndian)
          when 32
            io.write_bytes(sample.to_u32, IO::ByteFormat::LittleEndian)
          end
        end
      end
    end
  end
end
