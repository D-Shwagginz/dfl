class DFL
  # A chunk of data that holds info about data in the dfl
  class Head
    property type : HeadType = HeadType::Empty
    property name_length : UInt8 = 0_u8
    property name : String = ""
    property data : DataTypes = Empty.new

    # Reads in a head given the filepath
    def self.read(filename : String | Path)
      File.open(filename) do |io|
        read(io)
      end
    end

    # Reads in a head given the io
    def self.read(io : IO) : Head
      head = Head.new

      head.type = HeadType.new(io.read_bytes(UInt8, IO::ByteFormat::LittleEndian))
      head.name_length = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      head.name = io.gets(head.name_length).to_s

      case head.type
      when HeadType::Sound
        head.data = Sound.read(io)
      end

      head
    end

    # Creates a new sound head
    def self.new_sound(name : String = "NewSound", *, wav : IO | String | Path | Nil = nil) : Head
      head = Head.new
      head.type = HeadType::Sound
      head.name_length = name.size.to_u8
      head.name = name

      if wav
        head.data = Sound.from_wav(wav)
      else
        head.data = Sound.new
      end

      head
    end
  end

  # Empty head data
  struct Empty
  end
end
