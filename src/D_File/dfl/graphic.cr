class DFL
  # A color
  struct Color
    property r : UInt8 = 0_u8
    property g : UInt8 = 0_u8
    property b : UInt8 = 0_u8

    def initialize(r : UInt8 = 0, g : UInt8 = 0, b : UInt8 = 0)
      @r = r
      @g = g
      @b = b
    end

    def self.from_raylib(color : Raylib::Color) : Color
      Color.new(r: color.r, g: color.g, b: color.b)
    end

    def to_raylib : Raylib::Color
      Raylib::Color.new(r: r, g: g, b: b, a: 255)
    end
  end

  # A `DFL::Head`'s graphic data
  class Graphic
    # The width of the image
    property width : UInt32 = 0_u32
    # The height of the image
    property height : UInt32 = 0_u32
    # The x offset of the image
    property x_offset : Int16 = 0_i16
    # The y offset of the image
    property y_offset : Int16 = 0_i16
    # The image data
    property data : Array(Color | Nil) = [] of Color | Nil

    # Reads in a dfl graphic given the io
    def self.read(io : IO) : Graphic
      graphic = Graphic.new
      graphic.width = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      graphic.height = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

      graphic.x_offset = io.read_bytes(Int16, IO::ByteFormat::LittleEndian)
      graphic.y_offset = io.read_bytes(Int16, IO::ByteFormat::LittleEndian)

      color_byte_size = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      case color_byte_size
      when 8
        colors_size = io.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
      when 4
        colors_size = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      when 2
        colors_size = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      when 1
        colors_size = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      end

      colors = [] of Color

      if colors_size
        colors_size.times do
          color = Color.new
          color.r = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          color.g = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          color.b = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          colors << color
        end

        until graphic.data.size == (graphic.width*graphic.height)
          has_data = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian) == 1

          same_color_len_byte_size = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          case same_color_len_byte_size
          when 8
            same_color_len = io.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
          when 4
            same_color_len = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
          when 2
            same_color_len = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
          when 1
            same_color_len = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          end

          if same_color_len
            if has_data
              case color_byte_size
              when 8
                color_index = io.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
              when 4
                color_index = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
              when 2
                color_index = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
              when 1
                color_index = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
              end
              if color_index
                (same_color_len + 1).times do
                  graphic.data << colors[color_index]
                end
              end
            else
              (same_color_len + 1).times do
                graphic.data << nil
              end
            end
          end
        end
      end

      graphic
    end

    # Converts a graphic to a Raylib::Image
    def to_image : Raylib::Image
      image = Raylib.gen_image_color(@width, @height, Raylib::BLANK)

      width.times do |x|
        height.times do |y|
          pixel = data[x.to_i * width.to_i + y.to_i]
          next if pixel.nil?
          Raylib.image_draw_pixel(pointerof(image), x, y, pixel.as(Color).to_raylib)
        end
      end

      image
    end

    # Converts a Raylib::Image to a graphic
    def self.from_image(image : Raylib::Image) : Graphic
      graphic = Graphic.new
      graphic.width = image.width.to_u16
      graphic.height = image.height.to_u16

      graphic.width.times do |x|
        graphic.height.times do |y|
          color = Raylib.get_image_color(image, x, y)
          if color.a == 0
            graphic.data << nil
          else
            graphic.data << Color.from_raylib(color)
          end
        end
      end

      graphic
    end
  end
end
