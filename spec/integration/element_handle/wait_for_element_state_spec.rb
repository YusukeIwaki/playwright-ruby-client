require 'spec_helper'

RSpec.describe 'ElementHandle#wait_for_element_state' do
  it 'should wait for visible' do
    with_page do |page|
      page.content = "<div style='display:none'>content</div>"
      div = page.query_selector('div')
      done = false
      promise = Concurrent::Promises.future {
        div.wait_for_element_state('visible')
        done = true
      }
      give_it_a_chance_to_resolve(page)
      expect {
        div.evaluate("div => div.style.display = 'block'")
        promise.value!
      }.to change { done }.from(false).to(true)
    end
  end

  it 'should wait for already visible' do
    with_page do |page|
      page.content = '<div>content</div>'
      div = page.query_selector('div')
      Timeout.timeout(2) { div.wait_for_element_state('visible') }
    end
  end

  it 'should timeout waiting for visible' do
    with_page do |page|
      page.content = "<div style='display:none'>content</div>"
      div = page.query_selector('div')
      expect { div.wait_for_element_state('visible', timeout: 1000) }.to raise_error(/Timeout 1000ms exceeded/)
    end
  end

  it 'should throw waiting for visible when detached' do
    with_page do |page|
      page.content = "<div style='display:none'>content</div>"
      div = page.query_selector('div')
      promise = Concurrent::Promises.future { div.wait_for_element_state('visible') }
      sleep_a_bit_for_race_condition
      div.evaluate("div => div.remove()")
      expect { promise.value! }.to raise_error(/Element is not attached to the DOM/)
    end
  end

  it 'should wait for hidden' do
    with_page do |page|
      page.content = '<div>content</div>'
      div = page.query_selector('div')
      done = false
      promise = Concurrent::Promises.future {
        div.wait_for_element_state('hidden')
        done = true
      }
      give_it_a_chance_to_resolve(page)
      expect {
        div.evaluate("div => div.style.display = 'none'")
        promise.value!
      }.to change { done }.from(false).to(true)
    end
  end

  it 'should wait for already hidden' do
    with_page do |page|
      page.content = '<div></div>'
      div = page.query_selector('div')
      Timeout.timeout(2) { div.wait_for_element_state('hidden') }
    end
  end

  it 'should wait for hidden when detached' do
    with_page do |page|
      page.content = '<div>content</div>'
      div = page.query_selector('div')
      done = false
      promise = Concurrent::Promises.future {
        div.wait_for_element_state('hidden')
        done = true
      }
      give_it_a_chance_to_resolve(page)
      expect {
        div.evaluate("div => div.remove()")
        promise.value!
      }.to change { done }.from(false).to(true)
    end
  end

  it 'should wait for enabled button' do
    with_page do |page|
      page.content = '<button disabled><span>Target</span></button>'
      span = page.query_selector('text=Target')
      done = false
      promise = Concurrent::Promises.future {
        span.wait_for_element_state('enabled')
        done = true
      }
      give_it_a_chance_to_resolve(page)
      expect {
        span.evaluate("span => span.parentElement.disabled = false")
        promise.value!
      }.to change { done }.from(false).to(true)
    end
  end

  it 'should throw waiting for enabled when detached' do
    with_page do |page|
      page.content = '<button disabled>Target</button>'
      button = page.query_selector('button')
      promise = Concurrent::Promises.future { button.wait_for_element_state('enabled') }
      sleep_a_bit_for_race_condition
      button.evaluate("button => button.remove()")
      expect { promise.value! }.to raise_error(/Element is not attached to the DOM/)
    end
  end

  it 'should wait for disabled button' do
    with_page do |page|
      page.content = '<button><span>Target</span></button>'
      span = page.query_selector('text=Target')
      done = false
      promise = Concurrent::Promises.future {
        span.wait_for_element_state('disabled')
        done = true
      }
      give_it_a_chance_to_resolve(page)
      expect {
        span.evaluate("span => span.parentElement.disabled = true")
        promise.value!
      }.to change { done }.from(false).to(true)
    end
  end

  it 'should wait for stable position' do
    with_page do |page|
      page.content = '<button>Target</button>'
      button = page.query_selector('button')
      button.evaluate("button => { button.style.transition = 'margin 10000ms linear 0s'; button.style.marginLeft = '20000px'; }")

      done = false
      promise = Concurrent::Promises.future {
        button.wait_for_element_state('stable')
        done = true
      }
      give_it_a_chance_to_resolve(page)
      expect {
        button.evaluate("button => button.style.transition = ''")
        promise.value!
      }.to change { done }.from(false).to(true)
    end
  end

  it 'should wait for editable input' do
    with_page do |page|
      page.content = '<input readonly>'
      input = page.query_selector('input')
      done = false
      promise = Concurrent::Promises.future {
        input.wait_for_element_state('editable')
        done = true
      }
      give_it_a_chance_to_resolve(page)
      expect {
        input.evaluate("input => input.readOnly = false")
        promise.value!
      }.to change { done }.from(false).to(true)
    end
  end
end
