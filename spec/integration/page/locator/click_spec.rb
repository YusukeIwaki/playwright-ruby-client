require 'spec_helper'

RSpec.describe 'Locator' do
  it 'should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/button.html")
      button = page.locator('button')
      button.click
      expect(page.evaluate("() => window['result']")).to eq('Clicked')
    end
  end

  it 'should work with Node removed', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/button.html")
      page.evaluate("() => delete window['Node']")
      button = page.locator('button')
      button.click
      expect(page.evaluate("() => window['result']")).to eq('Clicked')
    end
  end

  it 'should double click the button', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/button.html")

      page.evaluate(<<~JAVASCRIPT)
      () => {
        window['double'] = false;
        const button = document.querySelector('button');
        button.addEventListener('dblclick', event => {
          window['double'] = true;
        });
      }
      JAVASCRIPT

      button = page.locator('button')
      button.dblclick
      expect(page.evaluate("() => window['double']")).to eq(true)
      expect(page.evaluate("() => window['result']")).to eq('Clicked')
    end
  end
end
