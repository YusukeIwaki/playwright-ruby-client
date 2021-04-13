require 'spec_helper'

# https://github.com/microsoft/playwright/blob/master/tests/chromium/js-coverage.spec.ts
RSpec.describe 'JS Coverage' do
  before { skip unless chromium? }

  def coverage_for(page, **kwargs, &block)
    page.start_js_coverage(**kwargs)
    block.call
    page.stop_js_coverage
  end

  it 'should work', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/jscoverage/simple.html", waitUntil: 'networkidle')
      end
      expect(coverage.size).to eq(1)
      expect(coverage.first['url']).to include('/jscoverage/simple.html')
      functions = coverage.first['functions']
      foo = functions.find { |fn| fn['functionName'] == 'foo' }
      expect(foo['ranges'].first['count']).to eq(1)
    end
  end

  it 'should report sourceURLs', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/jscoverage/sourceurl.html")
      end

      expect(coverage.size).to eq(1)
      expect(coverage.first['url']).to eq('nicename.js')
    end
  end

  it 'should ignore eval() scripts by default', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/jscoverage/eval.html")
      end

      expect(coverage.size).to eq(1)
    end
  end

  it "shouldn't ignore eval() scripts if reportAnonymousScripts is true", sinatra: true do
    with_page do |page|
      coverage = coverage_for(page, reportAnonymousScripts: true) do
        page.goto("#{server_prefix}/jscoverage/eval.html")
      end

      expect(coverage.size).to eq(2)
      found = coverage.find { |entry| entry['url'] == '' }
      expect(found['source']).to eq('console.log("foo")')
    end
  end

  it 'should report multiple scripts', sinatra: true do
    with_page do |page|
      coverage = coverage_for(page) do
        page.goto("#{server_prefix}/jscoverage/multiple.html")
      end
      expect(coverage.size).to eq(2)
      expect(coverage.map { |entry| entry['url'] }).to contain_exactly(
        include('/jscoverage/script1.js'),
        include('/jscoverage/script2.js'),
      )
    end
  end

  describe 'resetOnNavigation' do
    it 'should report scripts across navigations when disabled', sinatra: true do
      with_page do |page|
        coverage = coverage_for(page, resetOnNavigation: false) do
          page.goto("#{server_prefix}/jscoverage/multiple.html")
          page.goto(server_empty_page)
        end
        expect(coverage.size).to eq(2)
      end
    end

    it 'should NOT report scripts across navigations when enabled', sinatra: true do
      with_page do |page|
        coverage = coverage_for(page) do # Enabled by default
          page.goto("#{server_prefix}/jscoverage/multiple.html")
          page.goto(server_empty_page)
        end
        expect(coverage).to be_empty
      end
    end
  end

  it 'should not hang when there is a debugger statement', sinatra: true do
    Timeout.timeout(5) do
      with_page do |page|
        coverage_for(page) do
          page.goto(server_empty_page)
          page.evaluate('() => { debugger; }')
        end
      end
    end
  end
end
