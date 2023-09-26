# The main class for working with .dfl files
class DFL
  property data_num : UInt32 = 0_u32
  property empty : Array(Head) = [] of Head
  property sounds : Array(Head) = [] of Head

  alias DataTypes = Empty | Sound

  enum HeadType
    Empty
    Sound
  end

  def add(head : Head)
    case head.type
    when HeadType::Empty
      empty << head
    when HeadType::Sound
      sounds << head
    end
  end

  def self.read(filename : String | Path) : DFL
    File.open(filename) do |io|
      return read(io)
    end
  end

  def self.read(io : IO) : DFL
    dfl = DFL.new

    raise "Invalid DFL file" if io.gets(3) != "DFL"

    dfl.data_num = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    dfl.data_num.times do
      head = Head.read(io)

      case head.type
      when HeadType::Empty
        dfl.empty << head
      when HeadType::Sound
        dfl.sounds << head
      end
    end

    dfl
  end
end
