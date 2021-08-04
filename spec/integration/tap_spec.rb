require 'spec_helper'

RSpec.describe 'tap_point' do
  it 'should send well formed touch points' do
    with_page(hasTouch: true) do |page|
      promises = [
        Concurrent::Promises.future {
          page.evaluate(<<~JAVASCRIPT)
          () => new Promise(resolve => {
            document.addEventListener('touchstart', event => {
              resolve([...event.touches].map(t => ({
                identifier: t.identifier,
                clientX: t.clientX,
                clientY: t.clientY,
                pageX: t.pageX,
                pageY: t.pageY,
                radiusX: 'radiusX' in t ? t.radiusX : t['webkitRadiusX'],
                radiusY: 'radiusY' in t ? t.radiusY : t['webkitRadiusY'],
                rotationAngle: 'rotationAngle' in t ? t.rotationAngle : t['webkitRotationAngle'],
                force: 'force' in t ? t.force : t['webkitForce'],
              })));
            }, false);
          })
          JAVASCRIPT
        },
        Concurrent::Promises.future {
          page.evaluate(<<~JAVASCRIPT)
          () => new Promise(resolve => {
            document.addEventListener('touchend', event => {
              resolve([...event.touches].map(t => ({
                identifier: t.identifier,
                clientX: t.clientX,
                clientY: t.clientY,
                pageX: t.pageX,
                pageY: t.pageY,
                radiusX: 'radiusX' in t ? t.radiusX : t['webkitRadiusX'],
                radiusY: 'radiusY' in t ? t.radiusY : t['webkitRadiusY'],
                rotationAngle: 'rotationAngle' in t ? t.rotationAngle : t['webkitRotationAngle'],
                force: 'force' in t ? t.force : t['webkitForce'],
              })));
            }, false);
          })
          JAVASCRIPT
        },
      ]

      # make sure the evals hit the page
      page.evaluate('() => void 0')
      page.touchscreen.tap_point(40, 60)
      touchstart, touchend = Concurrent::Promises.zip(*promises).value!
      expect(touchstart).to eq([{
        'clientX' => 40,
        'clientY' => 60,
        'force' => 1,
        'identifier' => 0,
        'pageX' => 40,
        'pageY' => 60,
        'radiusX' => 1,
        'radiusY' => 1,
        'rotationAngle' => 0,
      }])
      expect(touchend).to be_empty
    end
  end
end
