require 'asciidoctor'
require 'asciidoctor/extensions'
require 'open-uri'

class CommonIncludeProcessor < Asciidoctor::Extensions::IncludeProcessor
  def handles? target
    (target.start_with? 'common')
  end

  def process doc, reader, target, attributes
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
    new_target = "docs/de/modules/"
    for string in split do
      # puts string
      if string.strip == "include" then
        next
      elsif string.start_with?("Unresolved directive") then
        next
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
    content = (open target).readlines.join('').force_encoding('utf-8')
    # puts content
    reader.push_include content, target, target, 1, attributes
    reader
  end
end

Asciidoctor::Extensions.register do
  include_processor CommonIncludeProcessor
end

