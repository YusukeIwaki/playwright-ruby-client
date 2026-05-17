require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/release-1.60/tests/page/expect-with-snapshot.spec.ts
RSpec.describe 'expect with aria snapshot', sinatra: true do
  include Playwright::Test::Matchers

  def failure_message
    yield
    raise 'Expected assertion to fail'
  rescue RSpec::Expectations::ExpectationNotMetError => err
    err.message
  end

  describe 'containment matchers print full element subtree' do
    it 'toHaveText failure includes full element subtree' do
      with_page do |page|
        page.content = '<section id=node><h1>Title</h1><p>Body</p></section>'

        message = failure_message { expect(page.locator('#node')).to have_text('nope', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('heading "Title"')
        expect(message).to include('paragraph')
        expect(message).to include('Body')
      end
    end

    it 'toContainText failure includes full element subtree' do
      with_page do |page|
        page.content = '<section id=node><h1>Title</h1><p>Body</p></section>'

        message = failure_message { expect(page.locator('#node')).to contain_text('nope', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('heading "Title"')
        expect(message).to include('Body')
      end
    end
  end

  describe 'property matchers print only the element line' do
    it 'toBeChecked failure prints just the input' do
      with_page do |page|
        page.content = '<label><input id=cb type=checkbox> a checkbox</label>'

        message = failure_message { expect(page.locator('#cb')).to be_checked(timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('checkbox')
      end
    end

    it 'toHaveAttribute failure clips descendant subtree' do
      with_page do |page|
        page.content = '<ul id=lst><li><h2>HeadingMarker</h2><p>BodyMarker</p></li></ul>'

        message = failure_message { expect(page.locator('#lst')).to have_attribute('data-x', 'yes', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('list')
        expect(message).to include('listitem')
        expect(message).not_to include('HeadingMarker')
        expect(message).not_to include('BodyMarker')
      end
    end

    it 'toHaveRole failure prints just the element line' do
      with_page do |page|
        page.content = '<button id=btn>Hi<span>nested</span></button>'

        message = failure_message { expect(page.locator('#btn')).to have_role('link', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('button')
      end
    end

    it 'toHaveValue failure prints the input element' do
      with_page do |page|
        page.content = '<input id=inp value="actual">'

        message = failure_message { expect(page.locator('#inp')).to have_value('expected', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('textbox')
      end
    end

    it 'toHaveCSS failure prints the element line' do
      with_page do |page|
        page.content = '<button id=btn style="color: red">Press</button>'

        message = failure_message { expect(page.locator('#btn')).to have_css('color', 'rgb(0, 0, 0)', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('button')
      end
    end
  end

  describe 'hidden or missing elements print full page snapshot' do
    it 'toBeVisible on hidden element prints full page snapshot' do
      with_page do |page|
        page.content = <<~HTML
          <div id=hidden style="display: none"><span>secret</span></div>
          <main><h1>Page Heading</h1></main>
        HTML

        message = failure_message { expect(page.locator('#hidden')).to be_visible(timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('heading "Page Heading"')
      end
    end

    it 'toBeVisible on missing element prints full page snapshot' do
      with_page do |page|
        page.content = '<header><h1>Hello</h1></header>'

        message = failure_message { expect(page.locator('#nope')).to be_visible(timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('heading "Hello"')
      end
    end

    it 'toHaveText on missing element prints full page snapshot' do
      with_page do |page|
        page.content = '<main><h1>Hello</h1></main>'

        message = failure_message { expect(page.locator('#missing')).to have_text('x', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('heading "Hello"')
      end
    end

    it 'toHaveTitle failure prints full page snapshot' do
      with_page do |page|
        page.content = '<title>Right</title><main><h1>Body Heading</h1></main>'

        message = failure_message { expect(page).to have_title('Wrong', timeout: 100) }
        expect(message).to include('Aria snapshot:')
        expect(message).to include('heading "Body Heading"')
      end
    end
  end

  describe 'matchers that should not include an aria snapshot' do
    it 'toHaveCount failure has no aria snapshot' do
      with_page do |page|
        page.content = '<ul><li>a</li><li>b</li></ul>'

        message = failure_message { expect(page.locator('li')).to have_count(5, timeout: 100) }
        expect(message).not_to include('Aria snapshot:')
      end
    end

    it 'toHaveText with array has no aria snapshot' do
      with_page do |page|
        page.content = '<ul><li>x</li><li>y</li></ul>'

        message = failure_message { expect(page.locator('li')).to have_text(['a', 'b', 'c'], timeout: 100) }
        expect(message).not_to include('Aria snapshot:')
      end
    end

    it 'toMatchAriaSnapshot failure has no extra aria snapshot section' do
      with_page do |page|
        page.content = '<button id=btn>Y</button>'

        message = failure_message { expect(page.locator('#btn')).to match_aria_snapshot('- button "X"', timeout: 100) }
        expect(message).not_to include('Aria snapshot:')
      end
    end
  end
end
