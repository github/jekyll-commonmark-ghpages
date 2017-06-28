# frozen-string-literal: true
# encoding: utf-8

require "commonmarker"
require "jekyll"
require "jekyll-commonmark"

# A customized version of CommonMarker::HtmlRenderer which outputs
# Kramdown-style header IDs.
class JekyllCommonMarkCustomRenderer < ::CommonMarker::HtmlRenderer
  def header(node)
    block do
      old_stream = @stream
      @stream = StringIO.new(String.new.force_encoding("utf-8"))
      out(:children)
      content = @stream.string
      @stream = old_stream

      id = generate_id(content)
      out("<h", node.header_level, "#{sourcepos(node)} id=\"#{id}\">",
          content, "</h", node.header_level, ">")
    end
  end

  private

  def generate_id(str)
    gen_id = basic_generate_id(str)
    gen_id = "section" if gen_id.empty?
    @used_ids ||= {}
    if @used_ids.key?(gen_id)
      gen_id += "-" << (@used_ids[gen_id] += 1).to_s
    else
      @used_ids[gen_id] = 0
    end
    gen_id
  end

  def basic_generate_id(str)
    gen_id = str.gsub(/^[^a-zA-Z]+/, "")
    gen_id.tr!("^a-zA-Z0-9 -", "")
    gen_id.tr!(" ", "-")
    gen_id.downcase!
    gen_id
  end
end

class Jekyll::Converters::Markdown
  # A Markdown renderer which uses JekyllCommonMarkCustomRenderer to output the
  # final document.
  class CommonMarkGhPages < CommonMark
    def convert(content)
      parse_options = (Set.new(@options) & CommonMarker::Config::Parse.keys).to_a
      render_options = (Set.new(@options) & CommonMarker::Config::Render.keys).to_a
      parse_options = :DEFAULT if parse_options.empty?
      render_options = :DEFAULT if render_options.empty?
      doc = CommonMarker.render_doc(content, parse_options, @extensions)
      JekyllCommonMarkCustomRenderer.new(
        :options => render_options,
        :extensions => @extensions
      ).render(doc)
    end
  end
end
