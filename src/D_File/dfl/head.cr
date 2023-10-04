class DFL
  # A chunk of data that holds info about data in the `DFL`
  class Head
    # The type of the head
    property type : HeadType = HeadType::Empty
    # The length of the name
    property name_length : UInt8 = 0_u8
    # The name
    property name : String = ""
    # The head's data
    property data : DataTypes = Empty.new

    # Reads in a head given the filepath
    # ```
    # head = DFL::Head.read("Path/To/MyHead.dpo")
    # ```
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
      when HeadType::Graphic
        head.data = Graphic.read(io)
      end

      head
    end

  # Empty `DFL::Head` data
  struct Empty
  end
end
