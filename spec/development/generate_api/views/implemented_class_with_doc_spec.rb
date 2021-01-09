require 'spec_helper'

RSpec.describe 'ImplementedClassWithDoc' do
  let(:instance) do
    ImplementedClassWithDoc.new(
      ClassDoc.new(api_json[class_name], root: api_json),
      klass,
      Dry::Inflector.new,
    )
  end
  subject { instance.lines.to_a.join("\n") }

  let(:api_json) do
    {
      'HogeHoge' => {
        'name' => 'HogeHoge',
        'extends' => 'EventEmitter',
        'methods' => {},
        'events' => {},
        'properties' => {},
      }
    }
  end
  let(:class_name) { 'HogeHoge' }
  around do |example|
    if ::Playwright::ChannelOwners.const_defined?(class_name)
      raise 'Already defined. Choose another class name for testing.'
    end

    ::Playwright::ChannelOwners.const_set(class_name, klass)
    begin
      example.run
    ensure
      ::Playwright::ChannelOwners.send(:remove_const, class_name)
    end
  end

  describe 'superclass' do
    context 'class extending Object' do
      before {
        api_json[class_name].delete('extends')
      }
      let(:klass) { Class.new(Array) }

      it 'should generate a class extending PlaywrightApi' do
        is_expected.to include('class HogeHoge < PlaywrightApi')
      end
    end

    context 'class extending EventEmitter' do
      before {
        api_json[class_name]['extends'] = 'EventEmitter'
      }
      let(:klass) { Class.new { include Playwright::EventEmitter } }

      it 'should generate a class extending PlaywrightApi' do
        is_expected.to include('class HogeHoge < PlaywrightApi')
      end
    end

    context 'class extending another playwright class' do
      before {
        api_json[class_name]['extends'] = 'HogeHogeBase'
        api_json['HogeHogeBase'] = {
          'name' => 'HogeHogeBase',
          'extends' => 'EventEmitter',
          'methods' => {},
          'events' => {},
          'properties' => {},
        }
      }
      let(:klass) { Class.new { include Playwright::EventEmitter } }

      it 'should generate a class extending base class' do
        is_expected.to include('class HogeHoge < HogeHogeBase')
      end
    end
  end

  describe 'implemented and documented method' do
    context 'without arguments' do
      before {
        api_json[class_name]['methods'] = {
          'awesomeCalc' => {
            'name' => 'awesomeCalc',
            'type' => { 'name' => 'number' },
            'required' => true,
            'args' => {},
          },
        }
      }
      let(:klass) do
        Class.new do
          def awesome_calc
            1
          end
        end
      end

      it 'should generate a method without argument nor block' do
        is_expected.to include("def awesome_calc\n")
      end
    end

    context 'with arguments' do
      before {
        api_json[class_name]['methods'] = {
          'awesomeCalc' => {
            'name' => 'awesomeCalc',
            'type' => { 'name' => 'number' },
            'required' => true,
            'args' => {
              'a' => {
                'name' => 'a',
                'type' => { 'name' => 'number' },
                'required' => true,
              },
              'options' => {
                'name' => 'options',
                'type' => {
                  'name' => 'Object',
                  'properties' => {
                    'b' => {
                      'name' => 'b',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                    'c' => {
                      'name' => 'c',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                  }
                },
                'required' => false,
              },
            },
          },
        }
      }
      let(:klass) do
        Class.new do
          def awesome_calc(a, b: 0, c: 0)
            a + b + c
          end
        end
      end

      it 'should generate a method with argument, without block' do
        is_expected.to include("def awesome_calc(a, b: nil, c: nil)\n")
      end
    end

    context 'with arguments size >= 4' do
      before {
        api_json[class_name]['methods'] = {
          'awesomeCalc' => {
            'name' => 'awesomeCalc',
            'type' => { 'name' => 'number' },
            'required' => true,
            'args' => {
              'a' => {
                'name' => 'a',
                'type' => { 'name' => 'number' },
                'required' => true,
              },
              'options' => {
                'name' => 'options',
                'type' => {
                  'name' => 'Object',
                  'properties' => {
                    'b' => {
                      'name' => 'b',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                    'c' => {
                      'name' => 'c',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                    'd' => {
                      'name' => 'd',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                    'e' => {
                      'name' => 'e',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                  }
                },
                'required' => false,
              },
            },
          },
        }
      }
      let(:klass) do
        Class.new do
          def awesome_calc(a, b: 0, c: 0, d: 0, e: 0)
            a + b + c + d + e
          end
        end
      end

      it 'should generate a method with argument with line breaks' do
        is_expected.to include("def awesome_calc(\n").and include("c: nil,\n").and include("e: nil)\n")
      end
    end

    context 'without arguments, with explicit block parameter' do
      before {
        api_json[class_name]['methods'] = {
          'awesomeCalc' => {
            'name' => 'awesomeCalc',
            'type' => { 'name' => 'Promise' },
            'required' => true,
            'args' => {},
          },
        }
      }
      let(:klass) do
        Class.new do
          def awesome_calc(&block)
            block.call
          end
        end
      end

      it 'should generate a method without argument, with block' do
        is_expected.to include("def awesome_calc(&block)\n")
      end
    end

    context 'with arguments, with explicit block parameter' do
      before {
        api_json[class_name]['methods'] = {
          'awesomeCalc' => {
            'name' => 'awesomeCalc',
            'type' => { 'name' => 'number' },
            'required' => true,
            'args' => {
              'a' => {
                'name' => 'a',
                'type' => { 'name' => 'number' },
                'required' => true,
              },
              'options' => {
                'name' => 'options',
                'type' => {
                  'name' => 'Object',
                  'properties' => {
                    'b' => {
                      'name' => 'b',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                    'c' => {
                      'name' => 'c',
                      'type' => { 'name' => 'number' },
                      'required' => false,
                    },
                  }
                },
                'required' => false,
              },
            },
          },
        }
      }
      let(:klass) do
        Class.new do
          def awesome_calc(a, b: 0, c: 0, &block)
            a + b + c
            block.call
          end
        end
      end

      it 'should generate a method with argument and block' do
        is_expected.to include("def awesome_calc(a, b: nil, c: nil, &block)\n")
      end
    end
  end

  describe 'unimplemented and documented method' do
  end

  describe 'implemented and undocumented method' do
    context 'without arguments' do
      let(:klass) do
        Class.new do
          def awesome_calc
            1
          end
        end
      end

      it 'should generate a method without argument nor block' do
        is_expected.to include("def awesome_calc\n")
      end
    end

    context 'with arguments' do
      let(:klass) do
        Class.new do
          def awesome_calc(a, b: 0, c: 0)
            a + b + c
          end
        end
      end

      it 'should generate a method with argument, without block' do
        is_expected.to include("def awesome_calc(a, b: nil, c: nil)\n")
      end
    end

    context 'without arguments, with explicit block parameter' do
      let(:klass) do
        Class.new do
          def awesome_calc(&block)
            block.call
          end
        end
      end

      it 'should generate a method without argument, with block' do
        is_expected.to include("def awesome_calc(&block)\n")
      end
    end

    context 'with arguments, with explicit block parameter' do
      let(:klass) do
        Class.new do
          def awesome_calc(a, b: 0, c: 0, &block)
            a + b + c
            block.call
          end
        end
      end

      it 'should generate a method with argument and block' do
        is_expected.to include("def awesome_calc(a, b: nil, c: nil, &block)\n")
      end
    end
  end
end
