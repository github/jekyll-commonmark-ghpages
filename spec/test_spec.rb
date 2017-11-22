require "spec_helper"

describe JekyllCommonMarkCustomRenderer do
  let(:renderer) { JekyllCommonMarkCustomRenderer.new }
  subject { renderer.render(doc) }

  context "headers" do
    let(:doc) { CommonMarker.render_doc("# Hello\n\n## Hi, world!") }
    it { is_expected.to match %r{<h1 id="hello">Hello</h1>} }
    it { is_expected.to match %r{<h2 id="hi-world">Hi, world!</h2>} }
  end

  context "code blocks" do
    let(:doc) { CommonMarker.render_doc("```ruby\nputs \"Hi!\"\n```\n") }
    it { is_expected.to match %r{<div class="language-ruby highlighter-rouge">} }
    it { is_expected.to match %r{<code><span class=".*?">puts</span> <span class=".*?">"Hi!"</span>} }
  end
end

describe Jekyll::Converters::Markdown::CommonMarkGhPages do
  let(:converter) { Jekyll::Converters::Markdown::CommonMarkGhPages.new(config) }
  let(:config) {
    {"commonmark" => {
      "options" => ["SMART", "FOOTNOTES"],
      "extensions" => ["tagfilter"],
    }}
  }
  subject { converter.convert("### \"Hi\" <xmp>[^nb]\n\n[^nb]: Yes.\n") }

  it { is_expected.to match %r{<h3 id="[^"]*">“Hi” &lt;xmp><sup[^>]*><a href="#fn1"[^>]*>\[1\]</a></sup></h3>\n<section class="footnotes">\n<ol>\n<li id="fn1">\n<p>Yes. <a href="#fnref1".*</a></p>} }
end
