class DFL
  # A `DFL::Head`'s palgraphic data
  class PalGraphic
    # The width of the image
    property width : UInt32 = 0_u32
    # The height of the image
    property height : UInt32 = 0_u32
    # The image data
    property data : Array(UInt64 | UInt32 | UInt16 | UInt8 | Nil) = [] of UInt64 | UInt32 | UInt16 | UInt8 | Nil

    # Reads in a dfl palgraphic given the io
    def self.read(io : IO) : PalGraphic
      palgraphic = Graphic.new
      palgraphic.width = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      palgraphic.height = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      color_byte_size = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)

      until palgraphic.data.size == (palgraphic.width*palgraphic.height)
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
                palgraphic.data << colors[color_index]
              end
            end
          else
            (same_color_len + 1).times do
              palgraphic.data << nil
            end
          end
        end
      end

      palgraphic
    end

    # Converts a palgraphic to a Raylib::Image
    def to_image(palette : Palette) : Raylib::Image
      image = Raylib.gen_image_color(@width, @height, Raylib::BLANK)

      width.times do |x|
        height.times do |y|
          pixel = palette.colors[data[x.to_i * width.to_i + y.to_i]]
          next if pixel.nil?
          Raylib.image_draw_pixel(pointerof(image), x, y, pixel)
        end
      end

      image
    end

    # Gets the absolute [Color Distance](https://en.wikipedia.org/wiki/Color_difference) between *color1* to *color*2
    def self.color_distance(color1 : Color, color2 : Color) : Int
      return (((color1.r.to_i - color2.r.to_i)**2) +
        ((color1.g.to_i - color2.g.to_i)**2) +
        ((color1.b.to_i - color2.b.to_i)**2)).abs
    end

    # Converts a `Raylib::Image` to a palgraphic
    #
    # NOTE: If you get an arithmetic overflow error at any point, chances are that your image is too big
    def self.from_image(image : Raylib::Image, palette : Palette) : PalGraphic
      # A tuple of the color, the index in the palette, and the distance to the current palette color
      current_closest_color : Tuple(Color, UInt8, Int32) = {Color.new, 0_u8, 0}
      palgraphic = PalGraphic.new

      palgraphic.width = image.width.to_u32
      palgraphic.height = image.height.to_u32

      image.height.times do |y|
        image.width.times do |x|
          current_image_color = Raylib.get_image_color(image, x, y)

          if current_image_color.a != 0
            palette_color = Color.new(
              r: palette.colors[0].r, g: palette.colors[0].g, b: palette.colors[0].b
            )

            current_closest_color = {palette_color, 0_u8, color_distance(current_image_color, palette_color)}

            palette.colors.each.with_index do |color, index|
              palette_color = Color.new(r: color.r, g: color.g, b: color.b)
              if (current_distance = color_distance(current_image_color, palette_color)) < current_closest_color[2]
                current_closest_color = {palette_color, index.to_u8, current_distance}
              end
            end

            palgraphic.data << current_closest_color[1]
          else
            palgraphic.data << nil
          end
        end
      end

      return palgraphic
    end

    # Converts a palgraphic to a graphic
    def to_graphic(palette : Palette) : Graphic
      graphic = Graphic.new
      graphic.width = width
      graphic.height = height

      data.each do |index|
        graphic.data << palette.colors[index]
      end

      graphic
    end

    # Converts a graphic to a palgraphic
    #
    # NOTE: If you get an arithmetic overflow error at any point, chances are that your image is too big
    def self.from_graphic(graphic : Graphic, palette : Palette) : PalGraphic
      # A tuple of the color, the index in the palette, and the distance to the current palette color
      current_closest_color : Tuple(Color, UInt8, Int32) = {Color.new, 0_u8, 0}
      palgraphic = PalGraphic.new

      palgraphic.width = graphic.width.to_u32
      palgraphic.height = graphic.height.to_u32

      graphic.height.times do |y|
        graphic.width.times do |x|
          current_graphic_color = graphic.data[x.to_i * width.to_i + y.to_i]

          if current_graphic_color.a != 0
            palette_color = Color.new(
              r: palette.colors[0].r, g: palette.colors[0].g, b: palette.colors[0].b
            )

            current_closest_color = {palette_color, 0_u8, color_distance(current_graphic_color, palette_color)}

            palette.colors.each.with_index do |color, index|
              palette_color = Color.new(r: color.r, g: color.g, b: color.b)
              if (current_distance = color_distance(current_graphic_color, palette_color)) < current_closest_color[2]
                current_closest_color = {palette_color, index.to_u8, current_distance}
              end
            end

            palgraphic.data << current_closest_color[1]
          else
            palgraphic.data << nil
          end
        end
      end

      return palgraphic
    end
  end
end
