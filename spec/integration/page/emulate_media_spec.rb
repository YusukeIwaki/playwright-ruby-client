require 'spec_helper'

RSpec.describe 'emulate media' do
  it 'should emulate type' do
    with_page do |page|
      expect(page.evaluate("() => matchMedia('screen').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('print').matches")).to eq(false)
      page.emulate_media(media: 'print')
      expect(page.evaluate("() => matchMedia('screen').matches")).to eq(false)
      expect(page.evaluate("() => matchMedia('print').matches")).to eq(true)
      page.emulate_media
      expect(page.evaluate("() => matchMedia('screen').matches")).to eq(false)
      expect(page.evaluate("() => matchMedia('print').matches")).to eq(true)
      page.emulate_media(media: 'null')
      expect(page.evaluate("() => matchMedia('screen').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('print').matches")).to eq(false)
    end
  end

  it 'should throw in case of bad media argument' do
    with_page do |page|
      expect { page.emulate_media(media: 'bad') }.to raise_error(/media: expected one of \(screen|print|no-override\)/)
    end
  end

  it 'should emulate colorScheme should work' do
    with_page do |page|
      page.emulate_media(colorScheme: 'light')
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: light)').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: dark)').matches")).to eq(false)
      page.emulate_media(colorScheme: 'dark')
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: dark)').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: light)').matches")).to eq(false)
    end
  end

  it 'should default to light' do
    with_page do |page|
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: light)').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: dark)').matches")).to eq(false)

      page.emulate_media(colorScheme: 'dark')
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: dark)').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: light)').matches")).to eq(false)

      page.emulate_media(colorScheme: 'null')
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: dark)').matches")).to eq(false)
      expect(page.evaluate("() => matchMedia('(prefers-color-scheme: light)').matches")).to eq(true)
    end
  end

  it 'should throw in case of bad colorScheme argument' do
    with_page do |page|
      expect { page.emulate_media(colorScheme: 'bad') }.to raise_error(/colorScheme: expected one of \(dark|light|no-preference|no-override\)/)
    end
  end

  it 'should change the actual colors in css' do
    with_page do |page|
      page.content = <<~HTML
      <style>
        @media (prefers-color-scheme: dark) {
          div {
            background: black;
            color: white;
          }
        }
        @media (prefers-color-scheme: light) {
          div {
            background: white;
            color: black;
          }
        }

      </style>
      <div>Hello</div>
      HTML

      page.emulate_media(colorScheme: 'light')
      expect(page.query_selector('div').evaluate('div => window.getComputedStyle(div).backgroundColor')).to eq('rgb(255, 255, 255)')

      page.emulate_media(colorScheme: 'dark')
      expect(page.query_selector('div').evaluate('div => window.getComputedStyle(div).backgroundColor')).to eq('rgb(0, 0, 0)')

      page.emulate_media(colorScheme: 'light')
      expect(page.query_selector('div').evaluate('div => window.getComputedStyle(div).backgroundColor')).to eq('rgb(255, 255, 255)')
    end
  end

  it 'should emulate reduced motion' do
    with_page do |page|
      expect(page.evaluate("() => matchMedia('(prefers-reduced-motion: no-preference)').matches")).to eq(true)
      page.emulate_media(reducedMotion: 'reduce')
      expect(page.evaluate("() => matchMedia('(prefers-reduced-motion: reduce)').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('(prefers-reduced-motion: no-preference)').matches")).to eq(false)
      page.emulate_media(reducedMotion: 'no-preference')
      expect(page.evaluate("() => matchMedia('(prefers-reduced-motion: reduce)').matches")).to eq(false)
      expect(page.evaluate("() => matchMedia('(prefers-reduced-motion: no-preference)').matches")).to eq(true)
      page.emulate_media(reducedMotion: nil)
    end
  end

  it 'should emulate forcedColors ' do
    with_page do |page|
      expect(page.evaluate("() => matchMedia('(forced-colors: none)').matches")).to eq(true)
      page.emulate_media(forcedColors: 'none')
      expect(page.evaluate("() => matchMedia('(forced-colors: none)').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('(forced-colors: active)').matches")).to eq(false)
      page.emulate_media(forcedColors: 'active')
      expect(page.evaluate("() => matchMedia('(forced-colors: none)').matches")).to eq(false)
      expect(page.evaluate("() => matchMedia('(forced-colors: active)').matches")).to eq(true)
      page.emulate_media(forcedColors: 'null')
      expect(page.evaluate("() => matchMedia('(forced-colors: none)').matches")).to eq(true)
    end
  end

  it 'should emulate contrast ' do
    with_page do |page|
      expect(page.evaluate("() => matchMedia('(prefers-contrast: no-preference)').matches")).to eq(true)
      page.emulate_media(contrast: 'no-preference')
      expect(page.evaluate("() => matchMedia('(prefers-contrast: no-preference)').matches")).to eq(true)
      expect(page.evaluate("() => matchMedia('(prefers-contrast: more)').matches")).to eq(false)
      page.emulate_media(contrast: 'more')
      expect(page.evaluate("() => matchMedia('(prefers-contrast: no-preference)').matches")).to eq(false)
      expect(page.evaluate("() => matchMedia('(prefers-contrast: more)').matches")).to eq(true)
      page.emulate_media(contrast: 'null')
      expect(page.evaluate("() => matchMedia('(prefers-contrast: no-preference)').matches")).to eq(true)
    end
  end
end
