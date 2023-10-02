class DFL
  # A `DFL::Head`'s palette data
  class Palette
    # Writes out the sound given the io
    def write(io : IO)
      if colors.size > UInt32::MAX
        io.write_bytes(8_u8, IO::ByteFormat::LittleEndian)
        io.write_bytes(colors.size.to_u64, IO::ByteFormat::LittleEndian)
      elsif colors.size > UInt16::MAX
        io.write_bytes(4_u8, IO::ByteFormat::LittleEndian)
        io.write_bytes(colors.size.to_u32, IO::ByteFormat::LittleEndian)
      elsif colors.size > UInt8::MAX
        io.write_bytes(2_u8, IO::ByteFormat::LittleEndian)
        io.write_bytes(colors.size.to_u16, IO::ByteFormat::LittleEndian)
      else
        io.write_bytes(1_u8, IO::ByteFormat::LittleEndian)
        io.write_bytes(colors.size.to_u8, IO::ByteFormat::LittleEndian)
      end

      colors.each do |color|
        io.write_bytes(color.r.to_u8, IO::ByteFormat::LittleEndian)
        io.write_bytes(color.g.to_u8, IO::ByteFormat::LittleEndian)
        io.write_bytes(color.b.to_u8, IO::ByteFormat::LittleEndian)
      end
    end
  end
end
