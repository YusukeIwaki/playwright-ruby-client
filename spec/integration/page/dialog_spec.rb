require 'spec_helper'

RSpec.describe 'dialog' do
  # https://github.com/microsoft/playwright/blob/v1.63.0/tests/page/page-dialog.spec.ts
  it 'should fire dialogclosed when dialog is accepted' do
    with_page do |page|
      closed = []
      context_closed = []
      page.on('dialogclosed', ->(dialog) { closed << dialog })
      page.context.on('dialogclosed', ->(dialog) { context_closed << dialog })
      opened = nil
      page.on('dialog', ->(dialog) { opened = dialog; dialog.accept })
      page.evaluate("() => alert('yo')")
      2.times { page.evaluate('() => 1') }
      expect(closed).to eq([opened])
      expect(context_closed).to eq([opened])
    end
  end

  it 'should fire dialogclosed when dialog is dismissed' do
    with_page do |page|
      page.on('dialog', ->(dialog) { dialog.dismiss })
      dialog = page.expect_event('dialogclosed') do
        page.evaluate("() => confirm('boolean?')")
      end
      expect(dialog.type).to eq('confirm')
      expect(dialog.message).to eq('boolean?')
    end
  end

  it 'should fire dialogclosed for auto-dismissed dialogs' do
    with_page do |page|
      dialog = page.context.expect_event('dialogclosed') do
        page.evaluate("() => alert('yo')")
      end
      expect(dialog.message).to eq('yo')
    end
  end

  it 'should fire' do
    with_page do |page|
      dialog_promise = Concurrent::Promises.resolvable_future
      page.once('dialog', ->(dialog) {
        dialog_promise.fulfill({
          type: dialog.type,
          default_value: dialog.default_value,
          message: dialog.message,
        })
        dialog.accept
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
      dialog_promise = Concurrent::Promises.resolvable_future
      page.once('dialog', ->(dialog) {
        dialog_promise.fulfill({
          type: dialog.type,
          default_value: dialog.default_value,
          message: dialog.message,
        })
        dialog.accept(promptText: 'answer!')
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
      page.once('dialog', ->(dialog) { dialog.accept })
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
      page.on('dialog', ->(dialog) { dialog.accept })
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
      page.on('dialog', ->(dialog) { dialog.accept })
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
