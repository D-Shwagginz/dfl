module WritingMethods
  module DFL
    # A `DFL::Head`'s palgraphic data
    module PalGraphic
      # Writes out the palgraphic given the io
      def write(io : IO)
        io.write_bytes(width.to_u32, IO::ByteFormat::LittleEndian)
        io.write_bytes(height.to_u32, IO::ByteFormat::LittleEndian)

        current_biggest_index = 0

        data.each do |index|
          current_biggest_index = index if index > current_biggest
        end

        if current_biggest_index > UInt32::MAX
          color_byte_size = 8
        elsif current_biggest_index > UInt16::MAX
          color_byte_size = 4
        elsif current_biggest_index > UInt8::MAX
          color_byte_size = 2
        else
          color_byte_size = 1
        end

        io.write_bytes(color_byte_size.to_u8, IO::ByteFormat::LittleEndian)

        current_pixel = 0

        until current_pixel == (width*height)
          color = data[current_pixel]
          same_color_len = 0
          if color
            data[current_pixel..].each_with_index do |same_color, index|
              if same_color != color
                same_color_len = index - 1
                break
              end
              same_color_len = index
            end

            io.write_bytes(1_u8, IO::ByteFormat::LittleEndian)

            if same_color_len > UInt32::MAX
              io.write_bytes(8_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u64, IO::ByteFormat::LittleEndian)
            elsif same_color_len > UInt16::MAX
              io.write_bytes(4_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u32, IO::ByteFormat::LittleEndian)
            elsif same_color_len > UInt8::MAX
              io.write_bytes(2_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u16, IO::ByteFormat::LittleEndian)
            else
              io.write_bytes(1_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u8, IO::ByteFormat::LittleEndian)
            end

            color_index = 0

            colors.each_with_index do |match, i|
              color_index = i if match.r == color.r && match.g == color.g && match.b == color.b
            end

            case color_byte_size
            when 8
              io.write_bytes(color_index.to_u64, IO::ByteFormat::LittleEndian)
            when 4
              io.write_bytes(color_index.to_u32, IO::ByteFormat::LittleEndian)
            when 2
              io.write_bytes(color_index.to_u16, IO::ByteFormat::LittleEndian)
            when 1
              io.write_bytes(color_index.to_u8, IO::ByteFormat::LittleEndian)
            end
          else
            data[current_pixel..].each_with_index do |same_color, index|
              if !same_color.nil?
                same_color_len = index - 1
                break
              end
              same_color_len = index
            end

            io.write_bytes(0_u8, IO::ByteFormat::LittleEndian)

            if same_color_len > UInt32::MAX
              io.write_bytes(4_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u64, IO::ByteFormat::LittleEndian)
            elsif same_color_len > UInt16::MAX
              io.write_bytes(3_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u32, IO::ByteFormat::LittleEndian)
            elsif same_color_len > UInt8::MAX
              io.write_bytes(2_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u16, IO::ByteFormat::LittleEndian)
            else
              io.write_bytes(1_u8, IO::ByteFormat::LittleEndian)
              io.write_bytes(same_color_len.to_u8, IO::ByteFormat::LittleEndian)
            end
          end
          current_pixel += same_color_len + 1
        end
      end
    end
  end
end
