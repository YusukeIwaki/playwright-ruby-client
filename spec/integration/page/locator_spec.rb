require 'spec_helper'

RSpec.describe 'locator' do

  example_group 'misc' do
    it 'should return bounding box', sinatra: true do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")
        element = page.locator('.box:nth-of-type(13)')
        box = element.bounding_box
        expect(box['x']).to eq(100)
        expect(box['y']).to eq(50)
        expect(box['width']).to eq(50)
        expect(box['height']).to eq(50)
      end
    end
  end
end
