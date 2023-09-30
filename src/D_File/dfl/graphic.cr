class DFL
  # A `DFL::Head`'s graphic data
  class Graphic
    # The width of the image
    property width : UInt32 = 0_u32
    # The height of the image
    property height : UInt32 = 0_u32
    # The image data
    property data : Array(Raylib::Color | Nil) = [] of Raylib::Color | Nil

    # Reads in a dfl grpahic given the io
    def self.read(io : IO) : Graphic
      graphic = Graphic.new
      graphic.width = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      graphic.height = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

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

      colors = [] of Raylib::Color

      if colors_size
        colors_size.times do
          color = Raylib::Color.new
          color.r = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          color.g = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          color.b = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
          color.a = 255
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
          Raylib.image_draw_pixel(pointerof(image), x, y, pixel.as(Raylib::Color))
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
            graphic.data << color
          end
        end
      end

      graphic
    end
  end
end
