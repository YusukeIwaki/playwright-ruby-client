require 'spec_helper'
require 'playwright/test'

RSpec.describe 'ariaSnapshot AI' do
  include Playwright::Test::Matchers

  it 'should generate refs' do
    with_page do |page|
      page.content = <<~HTML
      <button>One</button>
      <button>Two</button>
      <button>Three</button>
      HTML

      snapshot1 = page.locator('body').aria_snapshot(ref: true)
      expect(snapshot1).to include('- button "One" [ref=s1e3]')
      expect(snapshot1).to include('- button "Two" [ref=s1e4]')
      expect(snapshot1).to include('- button "Three" [ref=s1e5]')

      expect(page.locator('aria-ref=s1e3')).to have_text('One')
      expect(page.locator('aria-ref=s1e4')).to have_text('Two')
      expect(page.locator('aria-ref=s1e5')).to have_text('Three')

      snapshot2 = page.locator('body').aria_snapshot(ref: true)
      expect(snapshot2).to include('- button "One" [ref=s2e3]')
      expect(page.locator('aria-ref=s2e3')).to have_text('One')

      expect {
        expect(page.locator('aria-ref=s1e3')).to have_text('One')
      }.to raise_error(Playwright::Error, /Stale aria-ref, expected s2e{number}, got s1e3/)
    end
  end

  it 'should list iframes' do
    with_page do |page|
      page.content = <<~HTML
      <h1>Hello</h1>
      <iframe name="foo" src="data:text/html,<h1>World</h1>">
      HTML

      snapshot1 = page.locator('body').aria_snapshot(ref: true)
      expect(snapshot1).to include('- iframe')

      frame_snapshot = page.frame_locator('iframe').locator('body').aria_snapshot
      expect(frame_snapshot).to eq('- heading "World" [level=1]')
    end
  end

  # Helper method to recursively get aria snapshot for all frames
  def all_frame_snapshot(frame)
    snapshot = frame.locator('body').aria_snapshot(ref: true)
    lines = snapshot.split("\n")
    result = []
    lines.each do |line|
      match = line.match(/^(\s*)- iframe \[ref=(.*)\]/)
      unless match
        result << line
        next
      end

      leading_space = match[1]
      ref_id = match[2] # Renamed from 'ref' to avoid potential conflict
      child_frame = frame.frame_locator("aria-ref=#{ref_id}")
      child_snapshot = all_frame_snapshot(child_frame)
      result << (line + ':')
      result << child_snapshot.split("\n").map { |l| "#{leading_space}  #{l}" }.join("\n")
    end
    result.join("\n")
  end

  it 'ref mode can be used to stitch all frame snapshots', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/nested-frames.html")

      expected_snapshot = <<~SNAPSHOT.strip
  - iframe [ref=s1e3]:
    - iframe [ref=s1e3]:
      - text: Hi, I'm frame
    - iframe [ref=s1e4]:
      - text: Hi, I'm frame
  - iframe [ref=s1e4]:
    - text: Hi, I'm frame
      SNAPSHOT
      expect(all_frame_snapshot(page)).to eq(expected_snapshot)
    end
  end
end
