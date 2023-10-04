require "./write/**"

# Methods for writing DFL and dpo data
module WritingMethods
  # The main class for working with .dfl files
  module DFL
    # Writes out the dfl given the filename
    # ```
    # dfl = DFL.new
    # dfl.write("Path/To/MyDFL.dfl")
    # ```
    def write(filename : String | Path)
      File.open(filename, "w+") do |io|
        write(io)
      end
    end

    # Writes out the dfl given the io
    # ```
    # dfl = DFL.new
    # File.open("Path/To/MyDFL.dfl") do |io|
    #   dfl.write(io)
    # end
    # ```
    def write(io : IO)
      io.print(".DFL")

      data_num = empty.size + sounds.size

      io.write_bytes(data_num.to_u32, IO::ByteFormat::LittleEndian)

      empty.each do |head|
        head.write(io)
      end

      sounds.each do |head|
        head.write(io)
      end

      graphics.each do |head|
        head.write(io)
      end

      palette.write(head)

      palgraphics.each do |head|
        head.write(io)
      end
    end
  end
end

class DFL
  include WritingMethods::DFL
end

class DFL::Head
  include WritingMethods::DFL::Head
end

struct DFL::Empty
  include WritingMethods::DFL::Empty
end

class DFL::Sound
  include WritingMethods::DFL::Sound
end

class DFL::Graphic
  include WritingMethods::DFL::Graphic
end

class DFL::Palette
  include WritingMethods::DFL::Palette
end

class DFL::PalGraphic
  include WritingMethods::DFL::PalGraphic
end
