require 'spec_helper'

RSpec.describe 'strict mode' do
  it 'should fail page.text_content in strict mode' do
    with_page do |page|
      page.content = '<span>span1</span><div><span>target</span></div>'
      expect { page.text_content('span', strict: true) }.to raise_error(/strict mode violation/)
    end
  end

  it 'should fail page.get_attribute in strict mode' do
    with_page do |page|
      page.content = '<span>span1</span><div><span>target</span></div>'
      expect { page.get_attribute('span', 'id', strict: true) }.to raise_error(/strict mode violation/)
    end
  end

  it 'should fail page.fill in strict mode' do
    with_page do |page|
      page.content = '<input></input><div><input></input></div>'
      expect { page.fill('input', 'text', strict: true) }.to raise_error(/strict mode violation/)
    end
  end

  it 'should fail page.query_selector in strict mode' do
    with_page do |page|
      page.content = '<span>span1</span><div><span>target</span></div>'
      expect { page.query_selector('span', strict: true) }.to raise_error(/strict mode violation/)
    end
  end

  it 'should fail page.wait_for_selector in strict mode' do
    with_page do |page|
      page.content = '<span>span1</span><div><span>target</span></div>'
      expect { page.wait_for_selector('span', strict: true) }.to raise_error(/strict mode violation/)
    end
  end

  it 'should fail page.eval_on_selector in strict mode' do
    with_page do |page|
      page.content = '<span>span1</span><div><span>target</span></div>'
      expect { page.eval_on_selector('span', 'span => span.innerText', strict: true) }.to raise_error(/strict mode violation/)
    end
  end

  it 'should fail page.dispatch_event in strict mode' do
    with_page do |page|
      page.content = '<span>span1</span><div><span>target</span></div>'
      expect { page.dispatch_event('span', 'click', strict: true) }.to raise_error(/strict mode violation/)
    end
  end
end
