require 'spec_helper'

RSpec.describe 'Locator' do
  it 'input_value should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")

      page.fill('#textarea', 'text value')
      expect(page.input_value('#textarea')).to eq('text value')

      page.fill('#input', 'input value')
      expect(page.input_value('#input')).to eq('input value')

      handle = page.locator('#input')
      expect(handle.input_value).to eq('input value')

      expect {
        page.input_value('#inner')
      }.to raise_error(/Node is not an HTMLInputElement or HTMLTextAreaElement/)

      handle2 = page.locator('#inner')
      expect {
        handle2.input_value
      }.to raise_error(/Node is not an HTMLInputElement or HTMLTextAreaElement/)
    end
  end

  it 'inner_html should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.locator('#outer')
      expect(handle.inner_html).to eq("<div id=\"inner\">Text,\nmore text</div>")
      expect(page.inner_html('#outer')).to eq("<div id=\"inner\">Text,\nmore text</div>")
    end
  end

  it 'inner_text should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.locator('#inner')
      expect(handle.inner_text).to eq("Text, more text")
      expect(page.inner_text('#inner')).to eq("Text, more text")
    end
  end

  it 'text_content should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.locator('#inner')
      expect(handle.text_content).to eq("Text,\nmore text")
      expect(page.text_content('#inner')).to eq("Text,\nmore text")
    end
  end
end
