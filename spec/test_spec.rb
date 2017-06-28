require "spec_helper"

describe JekyllCommonMarkCustomRenderer do
  let(:renderer) { JekyllCommonMarkCustomRenderer.new }
  let(:doc) { CommonMarker.render_doc("# Hello\n\n## Hi, world!") }
  subject { renderer.render(doc) }

  it { is_expected.to match %r{<h1 id="hello">Hello</h1>} }
  it { is_expected.to match %r{<h2 id="hi-world">Hi, world!</h2>} }
end

describe Jekyll::Converters::Markdown::CommonMarkGhPages do
  it "works" do
  end
end
