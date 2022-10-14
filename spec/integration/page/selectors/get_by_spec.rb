require 'spec_helper'

RSpec.describe 'Page#getBy...' do
  it 'getByTestId should work' do
    with_page do |page|
      page.content = '<div><div data-testid="Hello">Hello world</div></div>'
      expect(page.get_by_test_id('Hello').text_content).to include('Hello world')
      expect(page.main_frame.get_by_test_id('Hello').text_content).to include('Hello world')
      expect(page.locator('div').get_by_test_id('Hello').text_content).to include('Hello world')
    end
  end

  it 'getByTestId should escape id' do
    with_page do |page|
      page.content = "<div><div data-testid='He\"llo'>Hello world</div></div>"
      expect(page.get_by_test_id('He"llo').text_content).to include('Hello world')
    end
  end

  it 'getByText should work' do
    with_page do |page|
      page.content = "<div>yo</div><div>ya</div><div>\nye  </div>"
      expect(page.get_by_text('ye').evaluate('el => el.outerHTML')).to eq("<div>\nye  </div>")
      expect(page.get_by_text(/ye/).evaluate('el => el.outerHTML')).to eq("<div>\nye  </div>")
      expect(page.get_by_text(/e/).evaluate('el => el.outerHTML')).to eq("<div>\nye  </div>")

      page.content = "<div> ye </div><div>ye</div>"
      expect(page.get_by_text('ye', exact: true).first.evaluate('el => el.outerHTML')).to eq('<div> ye </div>')

      page.content = "<div>Hello world</div><div>Hello</div>"
      expect(page.get_by_text('Hello', exact: true).first.evaluate('el => el.outerHTML')).to eq('<div>Hello</div>')
    end
  end

  it 'getByLabel should work' do
    with_page do |page|
      page.content = "<div><label for=target>Name</label><input id=target type=text></div>"
      expect(page.get_by_text('Name').evaluate('el => el.nodeName')).to eq('LABEL')
      expect(page.get_by_label('Name').evaluate('el => el.nodeName')).to eq('INPUT')
      expect(page.main_frame.get_by_label('Name').evaluate('el => el.nodeName')).to eq('INPUT')
      expect(page.locator('div').get_by_label('Name').evaluate('el => el.nodeName')).to eq('INPUT')
    end
  end

  it 'getByLabel should work with nested elements' do
    with_page do |page|
      page.content = "<label for=target>Last <span>Name</span></label><input id=target type=text>"

      expect(page.get_by_label('last name')['id']).to eq('target')
      expect(page.get_by_label('st na')['id']).to eq('target')
      expect(page.get_by_label('Name')['id']).to eq('target')
      expect(page.get_by_label('Last Name', exact: true)['id']).to eq('target')
      expect(page.get_by_label(/Last\s+name/i)['id']).to eq('target')

      expect(page.get_by_label('Last', exact: true).element_handles).to be_empty
      expect(page.get_by_label('last name', exact: true).element_handles).to be_empty
      expect(page.get_by_label('Name', exact: true).element_handles).to be_empty
      expect(page.get_by_label('what?').element_handles).to be_empty
      expect(page.get_by_label(/last name/).element_handles).to be_empty
    end
  end

  it 'getByPlaceholder should work' do
    with_page do |page|
      page.content = <<~HTML
      <div>
        <input placeholder='Hello'>
        <input placeholder='Hello World'>
      </div>
      HTML

      expect(page.get_by_placeholder('hello').count).to eq(2)
      expect(page.get_by_placeholder('Hello', exact: true).count).to eq(1)
      expect(page.get_by_placeholder(/wor/i).count).to eq(1)

      # Coverage
      expect(page.main_frame.get_by_placeholder('hello').count).to eq(2)
      expect(page.locator('div').get_by_placeholder('hello').count).to eq(2)
    end
  end

  it 'getByAltText should work' do
    with_page do |page|
      page.content = <<~HTML
      <div>
        <input alt='Hello'>
        <input alt='Hello World'>
      </div>
      HTML

      expect(page.get_by_alt_text('hello').count).to eq(2)
      expect(page.get_by_alt_text('Hello', exact: true).count).to eq(1)
      expect(page.get_by_alt_text(/wor/i).count).to eq(1)

      # Coverage
      expect(page.main_frame.get_by_alt_text('hello').count).to eq(2)
      expect(page.locator('div').get_by_alt_text('hello').count).to eq(2)
    end
  end

  it 'getByTitle should work' do
    with_page do |page|
      page.content = <<~HTML
      <div>
        <input title='Hello'>
        <input title='Hello World'>
      </div>
      HTML

      expect(page.get_by_title('hello').count).to eq(2)
      expect(page.get_by_title('Hello', exact: true).count).to eq(1)
      expect(page.get_by_title(/wor/i).count).to eq(1)

      # Coverage
      expect(page.main_frame.get_by_title('hello').count).to eq(2)
      expect(page.locator('div').get_by_title('hello').count).to eq(2)
    end
  end

  it 'getBy escaping' do
    with_page do |page|
      page.content = "<label id=label for=control>Hello my
wo\"rld</label><input id=control />"
      js = <<~JAVASCRIPT
      (input) => {
        input.setAttribute('placeholder', 'hello my\\nwo\"rld');
        input.setAttribute('title', 'hello my\\nwo\"rld');
        input.setAttribute('alt', 'hello my\\nwo\"rld');
      }
      JAVASCRIPT
      page.eval_on_selector('input', js)

      expect(page.get_by_text("hello my\nwo\"rld")['id']).to eq('label')
      expect(page.get_by_label("hello my\nwo\"rld")['id']).to eq('control')
      expect(page.get_by_placeholder("hello my\nwo\"rld")['id']).to eq('control')
      expect(page.get_by_alt_text("hello my\nwo\"rld")['id']).to eq('control')
      expect(page.get_by_title("hello my\nwo\"rld")['id']).to eq('control')

      page.content = "<label id=label for=control>Hello my
world</label><input id=control />"
      js = <<~JAVASCRIPT
      (input) => {
        input.setAttribute('placeholder', 'hello my\\nworld');
        input.setAttribute('title', 'hello my\\nworld');
        input.setAttribute('alt', 'hello my\\nworld');
      }
      JAVASCRIPT
      page.eval_on_selector('input', js)

      expect(page.get_by_text("hello my\nworld")['id']).to eq('label')
      expect(page.get_by_text("hello        my    world")['id']).to eq('label')
      expect(page.get_by_label("hello my\nworld")['id']).to eq('control')
      expect(page.get_by_placeholder("hello my\nworld")['id']).to eq('control')
      expect(page.get_by_alt_text("hello my\nworld")['id']).to eq('control')
      expect(page.get_by_title("hello my\nworld")['id']).to eq('control')
    end
  end
end
