require 'asciidoctor'
require 'asciidoctor/extensions'

class ChangeXref < Asciidoctor::Extensions::Preprocessor
  RX = /xref:.*#/
  SUB = "xref:"
  REFTEX = /\[.*\]/
  SUBREFTEX = "[]"

  def process document, reader
    return reader if reader.eof?
    replacement_lines = reader.read_lines.map do |line|
      # puts line
      # (line.include? 'xref:') ? ((line.gsub RX, SUB).gsub REFTEX, SUBREFTEX) : line
      (line.include? 'xref:') ? (line.gsub RX, SUB) : line

    end
    reader.unshift_lines replacement_lines
    reader
  end

end

Asciidoctor::Extensions.register do
  preprocessor ChangeXref
end

# Asciidoctor.convert_file 'sample-with-front-matter.adoc', :safe => :safe
