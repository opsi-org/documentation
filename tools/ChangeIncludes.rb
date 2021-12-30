require 'asciidoctor'
require 'asciidoctor/extensions'

class ChangeIncudes < Asciidoctor::Extensions::Preprocessor
  RX = /include::.*$/
  SUB = "include::"
  REFTEX = /\[.*\]/
  SUBREFTEX = "[]"

  def process document, reader
    # puts "process"
    return reader if reader.eof?
    replacement_lines = reader.read_lines.map do |line|
      # puts line
      if line.start_with? 'include::' or line.start_with? "Unresolved directive" then
        # puts "--------------------"
        line_split = line.split(/[:$]+/)
        new_line = "include::../../../"
        for string in line_split do
          # puts string
          if string.strip == "include" then
            next
          elsif string.start_with?("Unresolved directive") then
            next
          elsif string == "partial" then
            new_line.concat("partials/")
          elsif string.end_with?("[]") then
            new_line.concat(string)
          else
            new_line.concat(string)
            new_line.concat("/")
          end
        end
        # puts new_line
        new_line
        line = new_line
        # puts "--------------------"
      else
        # puts line
        line
      end

    end
    reader.unshift_lines replacement_lines
    reader
  end

end

Asciidoctor::Extensions.register do
  preprocessor ChangeIncudes
end

# Asciidoctor.convert_file 'sample.adoc', :safe => :safe
