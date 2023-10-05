module Cli
  def self.s_box(string : String) : String
    output = ""
    bottom_line = ""
    longest_len = 0
    line_len = 0

    string.lines.each { |line| longest_len = line.size if line.size > longest_len }

    string.lines.each do |line|
      line_len = 0
      output += "| "
      (longest_len//2 - line.size//2).times { output += " "; line_len += 1 }
      output += line
      line_len += line.size
      (longest_len - line_len).times { output += " "; line_len += 1 }
      output += " " if line_len != longest_len
      output += " |\n"
    end

    bottom_line += "+"
    (longest_len + 2).times { bottom_line += "-" }
    bottom_line += "+"

    output = "#{bottom_line}\n#{output}#{bottom_line}"

    output
  end

  def self.s_table(strings : Array(String)) : String
    output = ""
    bottom_line = ""
    longest_len = 0
    line_len = 0

    strings.each do |string|
      string.lines.each { |line| longest_len = line.size if line.size > longest_len }

      bottom_line += "+"
      (longest_len + 2).times { bottom_line += "-" }
      bottom_line += "+\n"

      string.lines.each do |line|
        line_len = 0
        output += "| "
        (longest_len//2 - line.size//2).times { output += " "; line_len += 1 }
        output += line
        line_len += line.size
        (longest_len - line_len).times { output += " "; line_len += 1 }
        output += " " if line_len != longest_len
        output += " |\n#{bottom_line}"
      end
    end
    
    output = "#{bottom_line}#{output}"

    output
  end
end
