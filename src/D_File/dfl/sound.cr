class DFL
  # A `DFL::Head`'s sound data
  class Sound
    # The number of channels in the dfl sound
    CHANNELS = 1_u16

    # The sample rate of the sound
    property sample_rate : UInt32 = 0_u32
    # The number of samples in the sound
    property samples_num : UInt32 = 0_u32
    # The number of bits per each sample
    property bits_per_sample : UInt16 = 0_u16
    # The samples
    property samples : Array(UInt8 | UInt16) = [] of UInt8 | UInt16

    # Reads in a dfl sound given the io
    def self.read(io : IO) : Sound
      sound = Sound.new
      sound.sample_rate = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      sound.samples_num = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      sound.bits_per_sample = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)

      (sound.samples_num*(8/sound.bits_per_sample)).to_u32.times do |i|
        case sound.bits_per_sample
        when 8
          sound.samples << io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        when 16
          sound.samples << io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
        end
      end
      sound
    end

    # Writes a dfl sound to a wav given the file path
    def to_wav(filename : String | Path) : UInt32
      File.open(filename, "w+") do |io|
        return to_wav(io)
      end
    end

    # Writes a dfl sound to a wav given the io
    def to_wav(io : IO) : UInt32
      file_size = 0_u32

      io << "RIFF"
      file_size += 4_u32
      # Size of the overall file - 8 bytes, in bytes (32-bit integer).
      io.write_bytes((4 + 24 + 8 + (samples.size.to_u32 * (bits_per_sample / 8))).to_u32, IO::ByteFormat::LittleEndian)
      file_size += 4_u32
      io << "WAVEfmt "
      file_size += 8_u32
      # Length of format data.
      io.write_bytes(16_u32, IO::ByteFormat::LittleEndian)
      file_size += 4_u32
      # Type of format (1 is PCM) - 2 byte integer.
      io.write_bytes(1_u16, IO::ByteFormat::LittleEndian)
      file_size += 2_u32
      # Number of Channels - 2 byte integer.
      io.write_bytes((CHANNELS).to_u16, IO::ByteFormat::LittleEndian)
      file_size += 2_u32
      # Sample Rate - 32 byte integer.
      io.write_bytes(sample_rate.to_u32, IO::ByteFormat::LittleEndian)
      file_size += 4_u32
      # (Sample Rate * BitsPerSample * Channels) / 8.
      io.write_bytes(((sample_rate.to_u32 * bits_per_sample * CHANNELS) / 8).to_u32, IO::ByteFormat::LittleEndian)
      file_size += 4_u32
      # (BitsPerSample * Channels) / 8 : 1 - 8 bit mono | /16 bit mono4 - 16 bit stereo : 2 - 8 bit stereo.
      io.write_bytes(((bits_per_sample * CHANNELS) / 8).to_u16, IO::ByteFormat::LittleEndian)
      file_size += 2_u32
      # Bits per sample.
      io.write_bytes(bits_per_sample.to_u16, IO::ByteFormat::LittleEndian)
      file_size += 2_u32
      io << "data"
      file_size += 4_u32
      # Size of the data section.
      io.write_bytes((samples.size.to_u32 * (bits_per_sample / 8)).to_u32, IO::ByteFormat::LittleEndian)
      file_size += 4_u32

      # Packs samples
      samples.each do |sample|
        io.write_bytes(sample, IO::ByteFormat::LittleEndian)
        file_size += (bits_per_sample/8).to_u32
      end

      return file_size
    end

    # Reads in a dfl sound from a wav given the file path
    def self.from_wav(filename : String | Path) : Sound
      File.open(filename) do |io|
        return from_wav(io)
      end
    end

    # Reads in a dfl sound from a wav given the io
    def self.from_wav(io : IO) : Sound
      sound = Sound.new

      # Reads "RIFF"
      io.gets(4)
      # Size of the overall file
      io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      # Reads "WAVEfmt "
      io.gets(8)
      # Length of format data
      io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      # Type of format (1 is PCM) - 2 byte integer
      io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      # Number of Channels
      channels = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      # Sample Rate
      sound.sample_rate = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      # (Sample Rate * BitsPerSample * Channels) / 8.
      io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      # (BitsPerSample * Channels) / 8 : 1 - 8 bit mono | /16 bit mono4 - 16 bit stereo : 2 - 8 bit stereo.
      io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      # Bits per sample
      sound.bits_per_sample = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      # Reads "data"
      io.gets(4)
      # Size of the data section
      sound.samples_num = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

      # Reads samples
      (sound.samples_num*(8/sound.bits_per_sample)).to_u32.times do |i|
        case sound.bits_per_sample
        when 8
          sound.samples << io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        when 16
          sound.samples << io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
        end
      end

      return sound
    end
  end
end
