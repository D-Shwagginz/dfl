# The main class for working with .dfl files
class DFL
  # The number of portions in the dfl
  property portions : UInt32 = 0_u32
  # The array of heads with empty data type
  property empty : Array(Head) = [] of Head
  # The array of heads with sound data type
  property sounds : Array(Head) = [] of Head
  # The array of heads with graphic data type
  property graphics : Array(Head) = [] of Head

  # The types that a `DFL::Head`'s data could be
  alias DataTypes = Empty | Sound | Graphic

  # The type of a `DFL::Head`
  enum HeadType
    Empty
    Sound
    Graphic
  end

  # Adds a `DFL::Head` to the dfl
  def add(head : Head)
    case head.type
    when HeadType::Empty
      empty << head
    when HeadType::Sound
      sounds << head
    when HeadType::Graphic
      graphics << head
    end
  end

  # Reads in a dfl given the filename
  # ```
  # dfl = DFL.read("Path/To/MyDFL.dfl")
  # ```
  def self.read(filename : String | Path) : DFL
    File.open(filename) do |io|
      return read(io)
    end
  end

  # Reads in a dfl given the io
  def self.read(io : IO) : DFL
    dfl = DFL.new

    raise "Invalid DFL file" if io.gets(4) != ".DFL"

    dfl.portions = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    dfl.portions.times do
      head = Head.read(io)

      case head.type
      when HeadType::Empty
        dfl.empty << head
      when HeadType::Sound
        dfl.sounds << head
      when HeadType::Graphic
        dfl.graphics << head
      end
    end

    dfl
  end
end
