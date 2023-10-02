class DFL
  # A `DFL::Head`'s palette data
  class Palette
    # The colors of the palette
    property colors = [] of Raylub::Color

    # Reads in a dfl palette given the io
    def self.read(io : IO) : Palette
      palette = Palette.new
      size_byte_size = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      case size_byte_size
      when 8
        size = io.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
      when 4
        size = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      when 2
        size = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      when 1
        size = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      end

      size.times do
        color = Raylib::Color.new
        color.r = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        color.g = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        color.b = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      end
    end
  end
end
