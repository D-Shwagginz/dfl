require "./write/**"

# The main class for writing .dfl files
class DFL
  # Writes out the dfl given the filename
  def write(filename : String | Path)
    File.open(filename, "w+") do |io|
      write(io)
    end
  end

  # Writes out the dfl given the io
  def write(io : IO)
    io.print("DFL")

    data_num = empty.size + sounds.size

    io.write_bytes(data_num.to_u32, IO::ByteFormat::LittleEndian)

    empty.each do |head|
      head.write(io)
    end

    sounds.each do |head|
      head.write(io)
    end
  end
end
