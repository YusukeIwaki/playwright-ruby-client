require 'spec_helper'

# https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/page-click-scroll.spec.ts
RSpec.describe 'page click scroll' do
  it 'should not scroll the page when scroll is "none"' do
    with_page do |page|
      page.set_content(<<~HTML)
        <div style="height: 2000px;"></div>
        <button onclick="window._clicked=true">click me</button>
      HTML

      error = begin
        page.locator('button').click(scroll: 'none', timeout: 2000)
        nil
      rescue => e
        e
      end
      expect(error.message).to include('element is outside of the viewport')
      expect(page.evaluate('() => window._clicked')).to be_falsy
      expect(page.evaluate('() => window.scrollY')).to eq(0)
    end
  end

  it 'should click in-viewport element when scroll is "none"' do
    with_page do |page|
      page.set_content(<<~HTML)
        <button onclick="window._clicked=true">click me</button>
        <div style="height: 2000px;"></div>
      HTML

      page.locator('button').click(scroll: 'none', timeout: 2000)
      expect(page.evaluate('() => window._clicked')).to eq(true)
      expect(page.evaluate('() => window.scrollY')).to eq(0)
    end
  end

  it 'should not scroll nested container when scroll is "none"' do
    with_page do |page|
      page.set_content(<<~HTML)
        <div style="height: 100px; width: 100px; overflow-y: scroll;">
          <div style="height: 50px;">A</div>
          <div style="height: 50px;">B</div>
          <button style="height: 50px; width: 100px;" onclick="window._clicked=true">C</button>
        </div>
      HTML

      button = page.locator('button')
      # The button is scrolled out of the nested overflow container.
      error = begin
        button.click(scroll: 'none', timeout: 2000)
        nil
      rescue => e
        e
      end
      expect(error).to be_truthy
      expect(page.evaluate('() => window._clicked')).to be_falsy

      # Default behavior scrolls the nested container into view and succeeds.
      button.click(timeout: 2000)
      expect(page.evaluate('() => window._clicked')).to eq(true)
    end
  end

  it 'should not scroll on hover when scroll is "none"' do
    with_page do |page|
      page.set_content(<<~HTML)
        <div style="height: 2000px;"></div>
        <div onmouseover="window._hovered=true" style="width: 50px; height: 50px;">hover me</div>
      HTML

      error = begin
        page.locator('div >> text=hover me').hover(scroll: 'none', timeout: 2000)
        nil
      rescue => e
        e
      end
      expect(error.message).to include('element is outside of the viewport')
      expect(page.evaluate('() => window._hovered')).to be_falsy
      expect(page.evaluate('() => window.scrollY')).to eq(0)
    end
  end
end
