class DFL
  class Head
    # Writes out the head given the filename
    def write(filename : String | Path)
      File.open(filename, "w+") do |io|
        write(io)
      end
    end

    # Writes out the head given the io
    def write(io : IO)
      io.write_bytes(type.to_u8, IO::ByteFormat::LittleEndian)
      trimmed_name = name[0..254]
      io.write_bytes(trimmed_name.size.to_u8, IO::ByteFormat::LittleEndian)
      io.print(trimmed_name)
      data.write(io)
    end
  end

  struct Empty
    # Write method so that it works with other data types
    def write(void)
    end
  end
end
