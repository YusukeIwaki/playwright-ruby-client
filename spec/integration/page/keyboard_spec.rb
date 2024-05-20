require 'spec_helper'

RSpec.describe 'page.keyboard' do
  it 'should type all kinds of characters', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/textarea.html")
      page.focus('textarea')
      text = 'This text goes onto two lines.\nThis character is 嗨.'
      page.keyboard.type(text)
      expect(page.eval_on_selector('textarea', 't => t.value')).to eq(text)
    end
  end

  it 'should type emoji', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/textarea.html")
      text = '👹 Tokyo street Japan 🇯🇵'
      page.type('textarea', text)
      expect(page.eval_on_selector('textarea', 'textarea => textarea.value')).to eq(text)
    end
  end

  it 'should handle selectAll', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/textarea.html")
      textarea = page.query_selector('textarea')
      textarea.type('some text')
      page.keyboard.down('ControlOrMeta')
      page.keyboard.press('a')
      page.keyboard.up('ControlOrMeta')
      page.keyboard.press('Backspace')
      expect(page.eval_on_selector('textarea', 'textarea => textarea.value')).to eq('')
    end
  end

  it 'should be able to prevent selectAll', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/textarea.html")
      textarea = page.query_selector('textarea')
      textarea.type('some text')

      page.eval_on_selector('textarea', <<~JAVASCRIPT)
        textarea => {
          textarea.addEventListener('keydown', event => {
            if (event.key === 'a' && (event.metaKey || event.ctrlKey))
              event.preventDefault();
          }, false);
        }
      JAVASCRIPT

      page.keyboard.down('ControlOrMeta')
      page.keyboard.press('a')
      page.keyboard.up('ControlOrMeta')
      page.keyboard.press('Backspace')
      expect(page.eval_on_selector('textarea', 'textarea => textarea.value')).to eq('some tex')
    end
  end
end
