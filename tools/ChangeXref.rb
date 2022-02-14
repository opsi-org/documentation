require 'asciidoctor'
require 'asciidoctor/extensions'


class ChangeXref < Asciidoctor::Extensions::Preprocessor
  RX = /xref:.*#/
  SUB = "xref:"
  REFTEX = /\[.*\]/
  SUBREFTEX = "[]"

# https://github.com/asciidoctor/asciidoctor-extensions-lab/issues/64
  def process document, reader
    # puts "ChangeXref"

    
    Asciidoctor::PreprocessorReader.new document, reader.lines.map {|line|
      line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
      line
     }

  end
end


class XrefIncludeProcessor < Asciidoctor::Extensions::IncludeProcessor
  def handles? target
    (target.start_with? 'docs/de/modules') or (target.start_with? 'docs/de/modules')
  end
  RX = /xref:.*#/
  SUB = "xref:"
  def process doc, reader, target, attributes
    # puts "XrefIncludeProcessor"
    content = (open target).readlines.map do |line|
      line = line.force_encoding('utf-8')
      line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
      line
    end 
    content = content.join('').force_encoding('utf-8')
    reader = reader.push_include content, target, target, 1, attributes
    reader
  end
end



Asciidoctor::Extensions.register do 
  preprocessor ChangeXref
  include_processor XrefIncludeProcessor  
end
