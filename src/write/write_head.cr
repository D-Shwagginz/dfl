module WritingMethods
  module DFL
    # A chunk of data that holds info about data in the `DFL`
    module Head
      # Writes out the head given the filename
      # ```
      # head = DFL::Head.new
      # head.write("Path/To/MyHead.dex")
      # ```
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

    # Empty `DFL::Head` data
    module Empty
      # Empty write method so that it works with other data types
      def write(void)
      end
    end
  end
end
