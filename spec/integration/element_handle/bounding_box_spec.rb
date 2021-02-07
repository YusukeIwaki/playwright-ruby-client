require 'spec_helper'

# ref: https://github.com/microsoft/playwright/blob/master/test/elementhandle-bounding-box.spec.ts
RSpec.describe 'ElementHandle#bounding_box' do
  it 'should work', sinatra: true do
    with_page do |page|
      page.viewport_size = { width: 500, height: 500 }
      page.goto("#{server_prefix}/grid.html")
      element_handle = page.query_selector('.box:nth-of-type(13)')
      box = element_handle.bounding_box
      expect(box).to eq({
        'x' => 100,
        'y' => 50,
        'width' => 50,
        'height' => 50,
      })
    end
  end

  it 'should handle nested frames', sinatra: true do
    with_page do |page|
      page.viewport_size = { width: 500, height: 500 }
      page.goto("#{server_prefix}/frames/nested-frames.html")
      nested_frame = page.frames.find { |frame| frame.name === 'dos' }
      element_handle = nested_frame.query_selector('div')
      box = element_handle.bounding_box
      expect(box).to eq({
        'x' => 24,
        'y' => 224,
        'width' => 268,
        'height' => 18,
      })
    end
  end

  xit 'should handle scroll offset and click' do
    #   await page.setContent(`
    #     <style>* { margin: 0; padding: 0; }</style>
    #     <div style="width:8000px; height:8000px;">
    #       <div id=target style="width:20px; height:20px; margin-left:230px; margin-top:340px;"
    #         onclick="window.__clicked = true">
    #       </div>
    #     </div>
    #   `);
    #   const elementHandle = await page.$('#target');
    #   const box1 = await elementHandle.boundingBox();
    #   await page.evaluate(() => window.scrollBy(200, 300));
    #   const box2 = await elementHandle.boundingBox();
    #   expect(box1).toEqual({ x: 230, y: 340, width: 20, height: 20 });
    #   expect(box2).toEqual({ x: 30, y: 40, width: 20, height: 20 });
    #   await page.mouse.click(box2.x + 10, box2.y + 10);
    #   expect(await page.evaluate(() => window['__clicked'])).toBe(true);
  end

  it 'should return null for invisible elements' do
    with_page do |page|
      page.content = '<div style="display:none">hi</div>'
      element = page.query_selector('div')
      expect(element.bounding_box).to be_nil
    end
  end

  xit 'should force a layout' do
    #   await page.setViewportSize({ width: 500, height: 500 });
    #   await page.setContent('<div style="width: 100px; height: 100px">hello</div>');
    #   const elementHandle = await page.$('div');
    #   await page.evaluate(element => element.style.height = '200px', elementHandle);
    #   const box = await elementHandle.boundingBox();
    #   expect(box).toEqual({ x: 8, y: 8, width: 100, height: 200 });
  end

  xit 'should work with SVG nodes' do
    #   await page.setContent(`
    #       <svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">
    #         <rect id="theRect" x="30" y="50" width="200" height="300"></rect>
    #       </svg>
    #     `);
    #   const element = await page.$('#therect');
    #   const pwBoundingBox = await element.boundingBox();
    #   const webBoundingBox = await page.evaluate(e => {
    #     const rect = e.getBoundingClientRect();
    #     return { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
    #   }, element);
    #   expect(pwBoundingBox).toEqual(webBoundingBox);
  end

  xit 'should work with page scale' do
    #   test.skip(browserName === 'firefox');
    # }, async ({ browser, server }) => {
    #   const context = await browser.newContext({ viewport: { width: 400, height: 400 }, isMobile: true });
    #   const page = await context.newPage();
    #   await page.goto(server.PREFIX + '/input/button.html');
    #   const button = await page.$('button');
    #   await button.evaluate(button => {
    #     document.body.style.margin = '0';
    #     button.style.borderWidth = '0';
    #     button.style.width = '200px';
    #     button.style.height = '20px';
    #     button.style.marginLeft = '17px';
    #     button.style.marginTop = '23px';
    #   });
    #   const box = await button.boundingBox();
    #   expect(Math.round(box.x * 100)).toBe(17 * 100);
    #   expect(Math.round(box.y * 100)).toBe(23 * 100);
    #   expect(Math.round(box.width * 100)).toBe(200 * 100);
    #   expect(Math.round(box.height * 100)).toBe(20 * 100);
    #   await context.close();
  end

  xit 'should work when inline box child is outside of viewport' do
    #   await page.setContent(`
    #       <style>
    #       i {
    #         position: absolute;
    #         top: -1000px;
    #       }
    #       body {
    #         margin: 0;
    #         font-size: 12px;
    #       }
    #       </style>
    #       <span><i>woof</i><b>doggo</b></span>
    #     `);
    #   const handle = await page.$('span');
    #   const box = await handle.boundingBox();
    #   const webBoundingBox = await handle.evaluate(e => {
    #     const rect = e.getBoundingClientRect();
    #     return { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
    #   });
    #   const round = box => ({
    #     x: Math.round(box.x * 100),
    #     y: Math.round(box.y * 100),
    #     width: Math.round(box.width * 100),
    #     height: Math.round(box.height * 100),
    #   });
    #   expect(round(box)).toEqual(round(webBoundingBox));
  end
end
