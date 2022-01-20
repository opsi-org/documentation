require 'asciidoctor'
require 'asciidoctor/extensions'
require 'open-uri'

class CommonIncludeProcessor < Asciidoctor::Extensions::IncludeProcessor
  def handles? target
    (target.start_with? 'common') or  (target.start_with? 'opsi-docs-en') or  (target.start_with? 'opsi-docs-de')
  end

  RX = /xref:.*#/
  SUB = "xref:"

  def process doc, reader, target, attributes
    puts "CommonIncludeProcessor"
    # puts reader.class
    # puts ENV.keys
    # puts Asciidoctor::Document::Title
    # puts doc.options().class
    # puts doc.options()[:attributes]["lang"]
    # puts doc.options()
    # puts ENV["LANG"]
    if doc.options()[:attributes]["lang"] == "de" then
      new_target = "docs/de/modules/"
    else
      new_target = "docs/en/modules/"
    end
    split = target.split(/[:$]+/)
    for string in split do
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
    new_target
    target = new_target
    puts target
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
  include_processor CommonIncludeProcessor
end

