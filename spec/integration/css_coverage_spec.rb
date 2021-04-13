require 'spec_helper'

# https://github.com/microsoft/playwright/blob/master/tests/chromium/css-coverage.spec.ts
RSpec.describe 'CSS Coverage' do
  before { skip unless chromium? }

  def coverage_for(page, **kwargs, &block)
    page.start_css_coverage(**kwargs)
    block.call
    page.stop_css_coverage
  end

  it 'should work', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/csscoverage/simple.html")
      end
      expect(coverage.size).to eq(1)
      expect(coverage.first['url']).to include('/csscoverage/simple.html')
      expect(coverage.first['ranges']).to eq([
        { 'start' => 1, 'end' => 22 },
      ])
      expect(coverage.first['text'][1...22]).to eq('div { color: green; }')
    end
  end

  it 'should report sourceURLs', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/csscoverage/sourceurl.html")
      end
      expect(coverage.size).to eq(1)
      expect(coverage.first['url']).to eq('nicename.css')
    end
  end

  it 'should report multiple stylesheets', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/csscoverage/multiple.html")
      end
      expect(coverage.size).to eq(2)
      expect(coverage.map{ |entry| entry['url'] }).to contain_exactly(
        include('/csscoverage/stylesheet1.css'),
        include('/csscoverage/stylesheet2.css'),
      )
    end
  end

  it 'should report stylesheets that have no coverage', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/csscoverage/unused.html")
      end
      expect(coverage.size).to eq(1)
      expect(coverage.first['url']).to eq('unused.css')
      expect(coverage.first['ranges']).to be_empty
    end
  end

  it 'should work with media queries', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/csscoverage/media.html")
      end
      expect(coverage.size).to eq(1)
      expect(coverage.first['url']).to include('/csscoverage/media.html')
      expect(coverage.first['ranges']).to contain_exactly({ 'start' => 17, 'end' => 38 })
    end
  end

  it 'should work with complicated usecases', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/csscoverage/involved.html")
      end
      expected_coverage = [
        {
          "url" => "http://localhost:<PORT>/csscoverage/involved.html",
          "ranges" => [
            {
              "start" => 149,
              "end" => 297
            },
            {
              "start" => 327,
              "end" => 433
            }
          ],
          "text" => "\n@charset \"utf-8\";\n@namespace svg url(http://www.w3.org/2000/svg);\n@font-face {\n  font-family: \"Example Font\";\n  src: url(\"./Dosis-Regular.ttf\");\n}\n\n#fluffy {\n  border: 1px solid black;\n  z-index: 1;\n  /* -webkit-disabled-property: rgb(1, 2, 3) */\n  -lol-cats: \"dogs\" /* non-existing property */\n}\n\n@media (min-width: 1px) {\n  span {\n    -webkit-border-radius: 10px;\n    font-family: \"Example Font\";\n    animation: 1s identifier;\n  }\n}\n"
        }
      ]
      expect(coverage.size).to eq(expected_coverage.size)
      aggregate_failures do
        coverage.each_with_index do |entry, i|
          expected_entry = expected_coverage[i]
          expect(entry['url']).to eq(expected_entry['url'].gsub('http://localhost:<PORT>', server_prefix))
          expect(entry['text']).to eq(expected_entry['text'])
          expect(entry['ranges']).to eq(expected_entry['ranges'])
        end
      end
    end
  end

  it 'should ignore injected stylesheets' do
    with_page do |page|
      coverage = coverage_for(page) do
        page.add_style_tag(content: 'body { margin: 10px;}')

        # trigger style recalc
        margin = page.evaluate("() => window.getComputedStyle(document.body).margin")
        raise "margin must be 10px here" unless margin == '10px'
      end
      expect(coverage).to be_empty
    end
  end

  it 'should work with a recently loaded stylesheet', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        js = <<~JAVASCRIPT
        async (url) => {
          document.body.textContent = 'hello, world';

          const link = document.createElement('link');
          link.rel = 'stylesheet';
          link.href = url;
          document.head.appendChild(link);
          await new Promise((x) => (link.onload = x));
        }
        JAVASCRIPT
        page.evaluate(js, arg: "#{server_prefix}/csscoverage/stylesheet1.css")
      end
      expect(coverage.size).to eq(1)
    end
  end

  describe 'resetOnNavigation' do
    it 'should report stylesheets across navigations', sinatra: true do
      with_page do |page|
        coverage = coverage_for(page, resetOnNavigation: false) do
          page.goto("#{server_prefix}/csscoverage/multiple.html")
          page.goto(server_empty_page)
        end
        expect(coverage.size).to eq(2)
      end
    end

    it 'should NOT report stylesheets across navigations', sinatra: true do
      with_page do |page|
        coverage = coverage_for(page) do # Enabled by default.
          page.goto("#{server_prefix}/csscoverage/multiple.html")
          page.goto(server_empty_page)
        end
        expect(coverage).to be_empty
      end
    end
  end
end
