require 'spec_helper'

# https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/locator-wait-for-function.spec.ts
RSpec.describe 'Locator#wait_for_function' do
  it 'should wait for an attribute to appear' do
    with_page do |page|
      page.set_content('<button id=toggle>Menu</button>')
      page.evaluate("() => setTimeout(() => document.querySelector('#toggle').setAttribute('aria-expanded', 'true'), 1000)")
      page.locator('#toggle').wait_for_function("element => element.hasAttribute('aria-expanded')")
    end
  end

  it 'should return immediately when already truthy' do
    with_page do |page|
      page.set_content('<div id=target>yes</div>')
      result = page.locator('#target').wait_for_function("element => element.textContent === 'yes'")
      expect(result).to be_nil
    end
  end

  it 'should accept ElementHandle arguments' do
    with_page do |page|
      page.set_content('<div id=a></div><div id=b>value</div>')
      handle = page.query_selector('#b')
      page.locator('#a').wait_for_function(
        "(element, other) => other.textContent === 'value'",
        arg: handle,
      )
    end
  end

  it 'should accept string expression' do
    with_page do |page|
      page.set_content('<div id=target>yes</div>')
      page.locator('#target').wait_for_function("element => element.textContent === 'yes'")
    end
  end

  it 'should resolve a promise returned by the predicate' do
    with_page do |page|
      page.set_content('<div id=target>yes</div>')
      page.locator('#target').wait_for_function("async element => element.textContent === 'yes'")
    end
  end

  it 'should wait for element to appear and survive rerender' do
    with_page do |page|
      page.set_content('<span>nothing here</span>')
      page.evaluate(<<~JAVASCRIPT)
        () => {
          let count = 0;
          let prev = null;
          const tick = () => {
            ++count;
            const next = document.createElement('div');
            next.id = 'target';
            next.textContent = String(count);
            if (prev)
              prev.remove();
            document.body.appendChild(next);
            prev = next;
            if (count < 3)
              setTimeout(tick, 500);
          };
          setTimeout(tick, 500);
        }
      JAVASCRIPT
      page.locator('#target').wait_for_function("element => element.textContent === '3'")
    end
  end

  it 'should throw when predicate throws' do
    with_page do |page|
      page.set_content('<div id=target>no</div>')
      expect {
        page.locator('#target').wait_for_function("() => { throw new Error('oh my'); }")
      }.to raise_error(/oh my/)
    end
  end

  it 'should throw on strict mode violation' do
    with_page do |page|
      page.set_content('<div class=x>1</div><div class=x>2</div>')
      expect {
        page.locator('div.x').wait_for_function('() => true')
      }.to raise_error(/strict mode violation/)
    end
  end
end
