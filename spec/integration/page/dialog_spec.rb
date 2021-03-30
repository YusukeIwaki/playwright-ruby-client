require 'spec_helper'

RSpec.describe 'dialog' do
  it 'should fire' do
    with_page do |page|
      dialog_promise = Playwright::AsyncValue.new
      page.once('dialog', ->(dialog) {
        dialog_promise.fulfill({
          type: dialog.type,
          default_value: dialog.default_value,
          message: dialog.message,
        })
        dialog.accept_async
      })
      page.evaluate('() => alert("yo")')

      expect(dialog_promise.value!).to eq({
        type: 'alert',
        default_value: '',
        message: 'yo',
      })
    end
  end

  it 'should allow accepting prompts' do
    with_page do |page|
      dialog_promise = Playwright::AsyncValue.new
      page.once('dialog', ->(dialog) {
        dialog_promise.fulfill({
          type: dialog.type,
          default_value: dialog.default_value,
          message: dialog.message,
        })
        dialog.accept_async(promptText: 'answer!')
      })
      result = page.evaluate("() => prompt('question?', 'yes.')")

      expect(dialog_promise.value!).to eq({
        type: 'prompt',
        default_value: 'yes.',
        message: 'question?',
      })
      expect(result).to eq('answer!')
    end
  end

  it 'should dismiss the prompt' do
    with_page do |page|
      page.once('dialog', ->(dialog) { dialog.dismiss })
      result = page.evaluate("() => prompt('question?')")
      expect(result).to be_nil
    end
  end

  it 'should accept the confirm prompt' do
    with_page do |page|
      page.once('dialog', ->(dialog) { dialog.accept_async })
      result = page.evaluate("() => confirm('boolean?')")
      expect(result).to eq(true)
    end
  end

  it 'should dismiss the confirm prompt' do
    with_page do |page|
      page.once('dialog', ->(dialog) { dialog.dismiss })
      result = page.evaluate("() => confirm('boolean?')")
      expect(result).to eq(false)
    end
  end

  it 'should handle multiple alerts' do
    with_page do |page|
      page.on('dialog', ->(dialog) { dialog.accept_async })
      page.content = <<~HTML
        <p>Hello World</p>
        <script>
          alert('Please dismiss this dialog');
          alert('Please dismiss this dialog');
          alert('Please dismiss this dialog');
        </script>
      HTML

      expect(page.text_content('p')).to eq('Hello World')
    end
  end

  it 'should handle multiple confirms' do
    with_page do |page|
      page.on('dialog', ->(dialog) { dialog.accept_async })
      page.content = <<~HTML
        <p>Hello World</p>
        <script>
          confirm('Please confirm me?');
          confirm('Please confirm me?');
          confirm('Please confirm me?');
        </script>
      HTML

      expect(page.text_content('p')).to eq('Hello World')
    end
  end

  it 'should auto-dismiss the prompt without listeners' do
    with_page do |page|
      result = page.evaluate("() => prompt('question?')")
      expect(result).to be_nil
    end
  end

  it 'should auto-dismiss the alert without listeners' do
    with_page do |page|
      page.content = '<div onclick="window.alert(123); window._clicked=true">Click me</div>'
      page.click('div')
      expect(page.evaluate('window._clicked')).to eq(true)
    end
  end
end
