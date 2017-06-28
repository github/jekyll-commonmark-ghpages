require "spec_helper"

describe JekyllCommonMarkCustomRenderer do
  let(:renderer) { JekyllCommonMarkCustomRenderer.new }
  let(:doc) { CommonMarker.render_doc("# Hello\n\n## Hi, world!") }
  subject { renderer.render(doc) }

  it { is_expected.to match %r{<h1 id="hello">Hello</h1>} }
  it { is_expected.to match %r{<h2 id="hi-world">Hi, world!</h2>} }
end

describe Jekyll::Converters::Markdown::CommonMarkGhPages do
  let(:converter) { Jekyll::Converters::Markdown::CommonMarkGhPages.new(config) }
  let(:config) {
    {"commonmark" => {
      "options" => ["SMART"],
      "extensions" => ["tagfilter"],
    }}
  }
  subject { converter.convert("### \"Hi\" <xmp>") }

  it { is_expected.to match %r{<h3 id="hi-ltxmp">“Hi” &lt;xmp></h3>} }
end
