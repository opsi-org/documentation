require 'asciidoctor'
require 'asciidoctor/reader'
require 'asciidoctor/extensions'




class MyReader < Asciidoctor::PreprocessorReader
  RX = /xref:.*#/
  SUB = "xref:"
  REFTEX = /\[.*\]/
  SUBREFTEX = "[]"

  # lines = 
  process_lines = false

  def read_lines
      lines = []
      # line = peek_line
      # puts "############"
     
      # puts source_lines
      while has_more_lines?
        line = shift
        line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
        # if (line.include? 'xref:')
        #   puts line
        # end
        look_ahead = 0
        lineno = 1
        process_lines = true
        lines.append(line)
        
        
      end
      # unshift_all lines
      lines
      # while peek_line
      #   line = shift 
      #   line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
      #   puts line
      #   line 
     
    
  end
  
end


class ChangeXref < Asciidoctor::Extensions::Preprocessor
  RX = /xref:.*#/
  SUB = "xref:"
  REFTEX = /\[.*\]/
  SUBREFTEX = "[]"

  # myreader = MyReader.new()
  
  def process document, reader
    # puts myreader.class
    puts "ChangeXref"
    # myreader = MyReader.new(document, reader.lines)
    # myreader.save
    # myreader.process_lines = true
    # puts myreader.class
    
    
    Asciidoctor::PreprocessorReader.new document, reader.lines.map {|line|
      
      # myreader.source_lines
     
      line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
      puts line
      line
     }
    #  new_reader.look_ahead = 0
    #  puts new_reader.lineno 
    #  puts new_reader.lines
    # myreader.restore_save
    # return new_reader
  end
end
    
    # return reader if reader.eof?
    # puts document.attributes

    # document = Asciidoctor.load_file reader.read_lines.join, safe: :unsafe, parse: false, attributes: document.attributes
    
    # puts "ChangeXref"
    # puts document.options()[:attributes]
    # myReader = Asciidoctor::PreprocessorReader.new document, reader.lines
    # puts myReader.class
    # replacement_lines = myReader.read_lines.map do |line|
    #   # puts line
    #   # (line.include? 'xref:') ? ((line.gsub RX, SUB).gsub REFTEX, SUBREFTEX) : line
    #   line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
    #   # (line.start_with? ':') ? (puts line) : line
    #   line
    # end

    # puts document.options()[:attributes]
   
    # myReader.unshift_lines replacement_lines
    # return myReader
    # return Asciidoctor::PreprocessorReader.new document, replacement_lines

    # puts replacement_lines
    # reader.process_lines=false
    # return Asciidoctor::PreprocessorReader.new document, reader.read_lines.map {|line|
    #   # do your stuff here..
    #   line
    #  }

    # nil
  # end

# end

# class MyPreprocessor < Asciidoctor::Extensions::Preprocessor

#   def handles? target
#     (target.start_with? 'xref:')
#   end

  

#   def process document, reader, target, attributes
#     puts "myPreprocessor"
#     puts reader.class
#     Asciidoctor::PreprocessorReader.new document, reader.lines.map {|line|
     
#       line
#      }
#   end
# end

# Asciidoctor::Extensions.register do
#   preprocessor MyPreprocessor
# end
  
class CommonIncludeProcessor < Asciidoctor::Extensions::IncludeProcessor
  def handles? target
    (target.start_with? 'common') or  (target.start_with? 'opsi-docs-en') or  (target.start_with? 'opsi-docs-de')
  end

  # reader = MyReader.new()

  RX = /xref:.*#/
  SUB = "xref:"
  REFTEX = /\[.*\]/
  SUBREFTEX = "[]"

  def process doc, reader, target, attributes
    puts "CommonIncludeProcessor"
    # reader = MyReader.new(doc, reader.lines)
   
  
    


    # puts reader.class
    # puts ENV.keys
    # puts Asciidoctor::Document::Title
    # puts doc.options().class
    # puts doc.options()[:attributes]["lang"]
    # puts doc.options()
    # puts ENV["LANG"]
    if doc.options()[:attributes]["lang"] == "de" then
      # puts "de"
      new_target = "docs/de/modules/"
    else
      # puts "en"
      new_target = "docs/en/modules/"
    end
    split = target.split(/[:$]+/)
    # new_target = "docs/de/modules/"
    for string in split do
      # puts string
      if string.strip == "include" then
        next
      elsif string.start_with?("Unresolved directive") then
        next
      elsif string.strip == "opsi-docs-en" then
        new_target = "docs/en/modules/"
      elsif string.strip == "opsi-docs-de" then
        new_target = "docs/de/modules/"
      elsif string == "partial" then
        new_target.concat("partials/")
      elsif string.end_with?(".asciidoc") or string.end_with?(".adoc") then
        new_target.concat(string)
      else
        new_target.concat(string)
        new_target.concat("/")
      end
    end
    # puts new_target
    new_target
    target = new_target
    puts target
    content = (open target).readlines.map do |line|
      line = line.force_encoding('utf-8')
      line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
      if (line.include? 'xref:')
        puts line
      end
      line
    end 
    puts content.class

    # content = (open target).readlines

    content = content.join('').force_encoding('utf-8')

    
    # puts content

    

    # content = (content.include? 'xref:') ? (content.gsub RX, SUB) : content
    
    # puts content
    reader = reader.push_include content, target, target, 1, attributes

    reader
    # Asciidoctor::PreprocessorReader.new doc, reader.lines
  end
end

class XrefIncludeProcessor < Asciidoctor::Extensions::IncludeProcessor
  def handles? target
    (target.start_with? 'docs/de/modules') or (target.start_with? 'docs/de/modules')
  end

  # reader = MyReader.new()

  RX = /xref:.*#/
  SUB = "xref:"
  REFTEX = /\[.*\]/
  SUBREFTEX = "[]"

  def process doc, reader, target, attributes
    puts "XrefIncludeProcessor"

    
    
    content = (open target).readlines.map do |line|
      line = line.force_encoding('utf-8')
      line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
      if (line.include? 'xref:')
        puts line
      end
      line
    end 
    puts content.class

    # content = (open target).readlines

    content = content.join('').force_encoding('utf-8')

    
    # puts content

    

    # content = (content.include? 'xref:') ? (content.gsub RX, SUB) : content
    
    # puts content
    reader = reader.push_include content, target, target, 1, attributes

    reader
    # Asciidoctor::PreprocessorReader.new doc, reader.lines
  end
end



class MyTreeProcessor < Asciidoctor::Extensions::TreeProcessor
  def process document
    puts "MyTreeProcessor"
    # puts document.attributes
    
    document
  end
end



Asciidoctor::Extensions.register do 
  preprocessor ChangeXref
  include_processor CommonIncludeProcessor
  include_processor XrefIncludeProcessor  
  
end





# require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

# include Asciidoctor

# A preprocessor that adds hardbreaks to the end of all lines.
#
# NOTE Asciidoctor already supports this feature via the hardbreaks attribute

# RX = /xref:.*#/
# SUB = "xref:"
# REFTEX = /\[.*\]/
# SUBREFTEX = "[]"

# Extensions.register {
#   preprocessor {
#     process {|document, reader|
#     Reader.new reader.readlines.map {|line|

#         if (line.include? 'xref:') 
#           line.gsub RX, SUB
#           puts line
#         end
#         line
#       }
#       false
#     }
#   }
# }
# class ChangeXref < Asciidoctor::Extensions::Preprocessor
#   def process doc, reader
#     lines = reader.lines
#     skipped = []
#     while !lines.empty? && !lines.first.start_with?('=')
#       skipped << lines.shift
#       reader.advance
#     end
#     doc.set_attr 'skipped', (skipped * "\n")
#     reader
#   end
# end


# class SamplePreprocessor < Asciidoctor::Extensions::Preprocessor
#   def process document, reader
   
#     lines = []
#     while reader.has_more_lines?
#       lines << reader.read_line # <2>
#     end
   
#     reader.process_lines = true
    
#     use_push_include = true
#     if use_push_include
#       reader.push_include lines, '<stdin>', '<stdin>' # <4>
#       puts reader.source_lines
#       puts reader.process_lines
#       Asciidoctor::Reader.new lines
#       # nil # <5>
#     else
#       puts reader.source_lines
#       puts reader.process_lines
#     Asciidoctor::Reader.new lines # <6>
#     end
#   end
# end


# class ChangeXref < Asciidoctor::Extensions::Preprocessor
#   def process document, reader
#     lines = []
#     Asciidoctor::PreprocessorReader.new document, reader.lines.map {|line|
      
#       puts reader.has_more_lines?
      
#       line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
#       lines.append line

#       line
#      }
    #  myreader.unshift_lines lines
    #  myreader
    


  #   puts reader.class
  #   lines = []
  #   while reader.peek_line
  #     line = reader.shift
  #     puts line
  #     lines.append line
  #     # reader.lines << reader.shift
  #   end
  #  reader.unshift_lines lines
  #  reader 
#   end
# end




# require 'asciidoctor'
# require 'asciidoctor/extensions'


# # require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

# # include Asciidoctor

# class ChangeXref < Asciidoctor::Extensions::Preprocessor

#   RX = /xref:.*#/
#   SUB = "xref:"
#   REFTEX = /\[.*\]/
#   SUBREFTEX = "[]"

#   def process document, reader
#     Asciidoctor::PreprocessorReader.new reader.readlines.map {|line|
#       (line.include? 'xref:') ? (line.gsub RX, SUB) : line
#       line
#     }
#   end


# end


# Asciidoctor::Extensions.register do
#   preprocessor SamplePreprocessor
# end


# Extensions.register {
#     preprocessor {
#       process {|document, reader|
#         Reader.new reader.readlines.map {|line|
#           (line.include? 'xref:') ? (line.gsub RX, SUB) : line
#         }
#       }
#     }
# }


# class ChangeXref < Asciidoctor::Extensions::Preprocessor
#   RX = /xref:.*#/
#   SUB = "xref:"
#   REFTEX = /\[.*\]/
#   SUBREFTEX = "[]"


#   def process document, reader
#         Reader.new reader.readlines.map {|l|
#           (line.include? 'xref:') ? (line.gsub RX, SUB) : line
#         }
#   end 
    

#   # def process document, reader 
#   #   # reader = Asciidoctor::PreprocessorReader.new document curser=reader
#   #   puts "2"
#   #   return reader if reader.eof?
#   #   replacement_lines = reader.read_lines.map do |line|
#   #     # puts line
#   #     # (line.include? 'xref:') ? ((line.gsub RX, SUB).gsub REFTEX, SUBREFTEX) : line
#   #     (line.include? 'xref:') ? (line.gsub RX, SUB) : line

#   #   end
#   #   reader.unshift_lines replacement_lines
#   #   puts reader.class
#   #   reader

#   #   # replacement_lines = []
#   #   # myReader = Asciidoctor::PreprocessorReader.new document, reader.read_lines.map {|line|
#   #   #   # puts line
#   #   #   new_line = (line.include? 'xref:') ? (line.gsub RX, SUB) : line
#   #   #   replacement_lines.append(new_line) 
#   #   #   (line.include? 'xref:') ? (line.gsub RX, SUB) : line
#   #   #   line
#   #   # }
#   #   # reader.unshift_lines replacement_lines
#   #   # puts replacement_lines
#   #   # puts myReader.class
#   #   # myReader

#   # end

# end


# Asciidoctor.convert_file 'sample-with-front-matter.adoc', :safe => :safe
