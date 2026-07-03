require 'spec_helper'

# ref: https://github.com/microsoft/playwright/blob/v1.61.1/tests/page/page-localstorage.spec.ts
RSpec.describe 'Page#local_storage / #session_storage', sinatra: true do
  it 'localStorage.items returns empty array on fresh origin' do
    with_page do |page|
      page.goto(server_empty_page)
      expect(page.local_storage.items).to eq([])
    end
  end

  it 'localStorage.getItem returns null for missing key' do
    with_page do |page|
      page.goto(server_empty_page)
      expect(page.local_storage.get_item('absent')).to be_nil
    end
  end

  it 'localStorage.setItem persists and surfaces in items()/getItem()' do
    with_page do |page|
      page.goto(server_empty_page)
      page.local_storage.set_item('alpha', '1')
      page.local_storage.set_item('beta', '2')

      expect(page.local_storage.items).to match_array([
        { 'name' => 'alpha', 'value' => '1' },
        { 'name' => 'beta', 'value' => '2' },
      ])
      expect(page.local_storage.get_item('alpha')).to eq('1')
      expect(page.evaluate("() => localStorage.getItem('alpha')")).to eq('1')
    end
  end

  it 'localStorage.setItem overwrites existing value' do
    with_page do |page|
      page.goto(server_empty_page)
      page.local_storage.set_item('k', 'first')
      page.local_storage.set_item('k', 'second')
      expect(page.local_storage.get_item('k')).to eq('second')
    end
  end

  it 'localStorage.removeItem removes a single item' do
    with_page do |page|
      page.goto(server_empty_page)
      page.local_storage.set_item('a', '1')
      page.local_storage.set_item('b', '2')

      page.local_storage.remove_item('a')
      expect(page.local_storage.items).to eq([{ 'name' => 'b', 'value' => '2' }])
    end
  end

  it 'localStorage.clear empties storage' do
    with_page do |page|
      page.goto(server_empty_page)
      page.local_storage.set_item('a', '1')
      page.local_storage.set_item('b', '2')

      page.local_storage.clear
      expect(page.local_storage.items).to eq([])
    end
  end

  it 'sessionStorage round-trip' do
    with_page do |page|
      page.goto(server_empty_page)
      expect(page.session_storage.items).to eq([])

      page.session_storage.set_item('s1', 'v1')
      page.session_storage.set_item('s2', 'v2')
      expect(page.session_storage.items).to match_array([
        { 'name' => 's1', 'value' => 'v1' },
        { 'name' => 's2', 'value' => 'v2' },
      ])
      expect(page.session_storage.get_item('s1')).to eq('v1')

      page.session_storage.remove_item('s1')
      expect(page.session_storage.items).to eq([{ 'name' => 's2', 'value' => 'v2' }])

      page.session_storage.clear
      expect(page.session_storage.items).to eq([])
    end
  end

  it 'localStorage and sessionStorage are independent' do
    with_page do |page|
      page.goto(server_empty_page)
      page.local_storage.set_item('shared', 'local')
      page.session_storage.set_item('shared', 'session')

      expect(page.local_storage.get_item('shared')).to eq('local')
      expect(page.session_storage.get_item('shared')).to eq('session')

      page.local_storage.clear
      expect(page.local_storage.items).to eq([])
      expect(page.session_storage.get_item('shared')).to eq('session')
    end
  end

  it 'storage methods are scoped to the current origin' do
    with_page do |page|
      page.goto("#{server_prefix}/empty.html")
      page.local_storage.set_item('k', 'origin-1')

      page.goto("#{server_cross_process_prefix}/empty.html")
      expect(page.local_storage.items).to eq([])
      page.local_storage.set_item('k', 'origin-2')

      page.goto("#{server_prefix}/empty.html")
      expect(page.local_storage.get_item('k')).to eq('origin-1')
    end
  end
end
