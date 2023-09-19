require 'spec_helper'

RSpec.describe 'popup' do
  it 'should work @smoke' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("() => window['__popup'] = window.open('about:blank')")
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(true)
    end
  end

  it 'should work with window features' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("() => window['__popup'] = window.open(window.location.href, 'Title', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=780,height=200,top=0,left=0')")
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(true)
    end
  end

  it 'should emit for immediately closed popups' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("() => { const win = window.open('about:blank'); win.close(); }")
      end
      expect(popup).not_to be_nil
    end
  end

  it 'should emit for immediately closed popups 2' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("() => { const win = window.open(window.location.href); win.close(); }")
      end
      expect(popup).not_to be_nil
    end
  end

  it 'should be able to capture alert' do
    with_page do |page|
      dialog = nil
      popup = page.expect_popup do
        dialog = page.context.expect_event('dialog') do
          Concurrent::Promises.future do
            page.evaluate("() => { const win = window.open(''); win.alert('hello'); }")
          end
        end
        expect(dialog.message).to eq('hello')
      end
      expect(dialog.page).to eq(popup)
      dialog.dismiss
    end
  end

  it 'should work with empty url' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("() => window['__popup'] = window.open('')")
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(true)
    end
  end

  it 'should work with noopener and no url' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("() => window['__popup'] = window.open(undefined, null, 'noopener')")
      end
      # Chromium reports `about:blank#blocked` here.
      expect(popup.url.split('#')[0]).to eq('about:blank')
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(false)
    end
  end

  it 'should work with noopener and about:blank' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("() => window['__popup'] = window.open('about:blank', null, 'noopener')")
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(false)
    end
  end

  it 'should work with noopener and url' do
    with_page do |page|
      popup = page.expect_popup do
        page.evaluate("url => window['__popup'] = window.open(url, null, 'noopener')", arg: page.url)
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(false)
    end
  end

  it 'should work with clicking target=_blank', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = '<a target=_blank rel="opener" href="/one-style.html">yo</a>'
      popup = page.expect_popup do
        page.click('a')
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(true)
      expect(popup.main_frame.page).to eq(popup)
    end
  end

  it 'should work with fake-clicking target=_blank and rel=noopener', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = '<a target=_blank rel=noopener href="/one-style.html">yo</a>'
      popup = page.expect_popup do
        page.eval_on_selector('a', 'a => a.click()')
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(false)
    end
  end

  it 'should work with clicking target=_blank and rel=noopener', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = '<a target=_blank rel=noopener href="/one-style.html">yo</a>'
      popup = page.expect_popup do
        page.click('a')
      end
      expect(page.evaluate('() => !!window.opener')).to eq(false)
      expect(popup.evaluate('() => !!window.opener')).to eq(false)
    end
  end

  # it('should not treat navigations as new popups', async ({ page, server, isWebView2 }) => {
  #   it.skip(isWebView2, 'Page.close() is not supported in WebView2');

  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent('<a target=_blank rel=noopener href="/one-style.html">yo</a>');
  #   const [popup] = await Promise.all([
  #     page.waitForEvent('popup'),
  #     page.click('a'),
  #   ]);
  #   let badSecondPopup = false;
  #   page.on('popup', () => badSecondPopup = true);
  #   await popup.goto(server.CROSS_PROCESS_PREFIX + '/empty.html');
  #   await page.close();
  #   expect(badSecondPopup).toBe(false);
  # });

  it 'should report popup opened from iframes', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/two-frames.html")
      frame = page.frame(name: 'uno')
      expect(frame).not_to be_nil
      popup = page.expect_popup do
        frame.evaluate("() => window['__popup'] = window.open('')")
      end
      expect(popup).not_to be_nil
    end
  end
end
