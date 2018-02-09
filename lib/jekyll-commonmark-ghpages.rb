# frozen-string-literal: true
# encoding: utf-8

require "commonmarker"
require "jekyll"
require "jekyll-commonmark"
require "rouge"

# A customized version of CommonMarker::HtmlRenderer which:
# - outputs Kramdown-style header IDs.
# - performs syntax highlighting in code blocks.
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

  def code_block(node)
    lang = if node.fence_info && !node.fence_info.empty?
             node.fence_info.split(/[\s,]/)[0]
           end

    content = node.string_content

    if lang && lexer = ::Rouge::Lexer.find_fancy(lang, content)
      block do
        out("<div class=\"language-#{lang} highlighter-rouge\">")
        out(::Rouge::Formatters::HTMLLegacy.new(css_class: 'highlight').format(lexer.lex(content)))
        out("</div>")
      end
      return
    end

    if option_enabled?(:GITHUB_PRE_LANG)
      out("<pre#{sourcepos(node)}")
      out(' lang="', lang, '"') if lang
      out('><code>')
    else
      out("<pre#{sourcepos(node)}><code")
      out(' class="language-', lang, '">') if lang
      out('>')
    end
    out(escape_html(content))
    out('</code></pre>')
  end

  private

  def generate_id(str)
    gen_id = basic_generate_id(str)
    gen_id = "section" if gen_id.empty?
    @used_ids ||= {}
    if @used_ids.key?(gen_id)
      gen_id += "-" + (@used_ids[gen_id] += 1).to_s
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
      html = JekyllCommonMarkCustomRenderer.new(
        :options => render_options,
        :extensions => @extensions
      ).render(doc)
      html.gsub(/<br data-jekyll-commonmark-ghpages />/, "\n")
    end
  end
end

class Jekyll::Tags::HighlightBlock
  alias render_rouge_without_ghpages_hack render_rouge

  def render_rouge(context)
    render_rouge_without_ghpages_hack(context)
      .gsub(/\r?\n/, "<br data-jekyll-commonmark-ghpages>")
  end
end
