require 'spec_helper'

RSpec.describe 'Locator' do
  it 'should work' do
    with_page do |page|
      page.content = '<html><body><div class="tweet"><div class="like">100</div><div class="retweets">10</div></div></body></html>'
      tweet = page.locator('.tweet .like')
      content = tweet.evaluate('node => node.innerText')
      expect(content).to eq('100')
    end
  end

  it 'should retrieve content from subtree' do
    with_page do |page|
      page.content = '<div class="a">not-a-child-div</div><div id="myId"><div class="a">a-child-div</div></div>'
      locator = page.locator('#myId').locator('.a')
      content = locator.evaluate('node => node.innerText')
      expect(content).to eq('a-child-div')
    end
  end

  it 'should work for all' do
    with_page do |page|
      page.content = '<html><body><div class="tweet"><div class="like">100</div><div class="like">10</div></div></body></html>'
      tweet = page.locator('.tweet .like')
      content = tweet.evaluate_all('nodes => nodes.map(n => n.innerText)')
      expect(content).to eq(%w[100 10])
    end
  end

  it 'should retrieve content from subtree for all' do
    with_page do |page|
      page.content = '<div class="a">not-a-child-div</div><div id="myId"><div class="a">a1-child-div</div><div class="a">a2-child-div</div></div>'
      locator = page.locator('#myId').locator('.a')
      content = locator.evaluate_all('nodes => nodes.map(n => n.innerText)')
      expect(content).to eq(%w[a1-child-div a2-child-div])
    end
  end

  it 'should not throw in case of missing selector for all' do
    with_page do |page|
      page.content = '<div class="a">not-a-child-div</div><div id="myId"></div>'
      locator = page.locator('#myId').locator('.a')
      expect(locator.evaluate_all('nodes => nodes.length')).to eq(0)
    end
  end
end
