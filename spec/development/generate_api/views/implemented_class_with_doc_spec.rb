require 'spec_helper'

RSpec.describe 'ImplementedClassWithDoc' do
  let(:instance) do
    ImplementedClassWithDoc.new(
      ClassDoc.new(api_json_hogehoge, root: api_json),
      klass,
      Dry::Inflector.new,
    )
  end
  subject { instance.lines.to_a.join("\n") }

  let(:api_json_hogehoge) do
    {
      'langs' => {},
      'name' => 'HogeHoge',
      'extends' => 'EventEmitter',
      'members' => [],
    }
  end
  let(:api_json) { [api_json_hogehoge] }
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
        api_json_hogehoge.delete('extends')
      }
      let(:klass) { Class.new(Array) }

      it 'should generate a class extending PlaywrightApi' do
        is_expected.to include('class HogeHoge < PlaywrightApi')
      end
    end

    context 'class extending EventEmitter' do
      before {
        api_json_hogehoge['extends'] = 'EventEmitter'
      }
      let(:klass) { Class.new { include Playwright::EventListenerInterface } }

      it 'should generate a class extending PlaywrightApi' do
        is_expected.to include('class HogeHoge < PlaywrightApi')
      end
    end

    context 'class extending another playwright class' do
      before {
        api_json_hogehoge['extends'] = 'HogeHogeBase'
        api_json << {
          'kind' => 'method',
          'langs' => {},
          'name' => 'HogeHogeBase',
          'extends' => 'EventEmitter',
          'members' => [],
        }
      }
      let(:klass) { Class.new { include Playwright::EventListenerInterface } }

      it 'should generate a class extending base class' do
        is_expected.to include('class HogeHoge < HogeHogeBase')
      end
    end
  end

  def json_type(name)
    { 'name' => name }
  end

  def json_overrides(python: nil, js: nil)
    { 'python' => python, 'js' => js }.compact
  end

  def json_langs(only: nil, overrides: {})
    only = [only] if only && !only.is_a?(Array)

    { 'only' => only, 'overrides' => overrides }.compact
  end

  def json_method(name, args = [], langs: {}, type: nil)
    {
      'kind' => 'method',
      'langs' => langs,
      'name' => name,
      'type' => type || json_type('number'),
      'required' => true,
      'args' => args,
    }
  end

  def json_arg(name, type, required: false, langs: {})
    {
      'kind' => 'property',
      'langs' => langs,
      'name' => name,
      'required' => required,
    }
  end

  def required_arg(name, type, langs: {})
    json_arg(name, type, langs: langs, required: true)
  end

  def optional_arg(name, type, langs: {})
    json_arg(name, type, langs: langs, required: false)
  end

  def object_arg(name, properties, langs: {}, required: false)
    {
      'kind' => 'property',
      'langs' => langs,
      'name' => name,
      'type' => {
        'name' => 'Object',
        'properties' => properties,
      },
      'required' => required,
    }
  end

  def optional_kwarg(name, properties, langs: {})
    object_arg(name, properties, langs: langs, required: false)
  end

  describe 'implemented and documented method' do
    context 'without arguments' do
      before {
        api_json_hogehoge['members'] << json_method('awesomeCalc')
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
        api_json_hogehoge['members'] << json_method('awesomeCalc', [
          required_arg('a', json_type('number')),
          optional_kwarg('options', [
            optional_arg('b', json_type('number'), langs: json_langs(only: %w(js java))),
            optional_arg('bOnlyForPython', json_type('number'), langs: json_langs(only: 'python')),
            optional_arg('c', json_type('number')),
          ])
        ])
      }
      let(:klass) do
        Class.new do
          def awesome_calc(a, b: 0, c: 0)
            a + b + c
          end
        end
      end

      it 'should generate a method with argument, without block' do
        is_expected.to include("def awesome_calc(a, bOnlyForPython: nil, c: nil)\n")
      end
    end

    context 'with options and python-only optional parameters' do
      before {
        api_json_hogehoge['members'] << json_method('awesomeCalc', [
          required_arg('values', json_type('number'), langs: json_langs(only: %w(js java))),
          optional_kwarg('options', [
            optional_arg('ruby', json_type('number')),
          ]),
          optional_arg('python', json_type('number'), langs: json_langs(only: 'python')),
        ])
      }
      let(:klass) do
        Class.new do
          def awesome_calc(ruby: nil, python: nil)
          end
        end
      end

      it 'should generate a method with argument, without block' do
        is_expected.to include("def awesome_calc(python: nil, ruby: nil)\n")
      end
    end

    context 'with overrides' do
      before {
        api_json_hogehoge['members'] << json_method('awesomeCalc', [
          required_arg('values', json_type('number'), langs: json_langs(
            overrides: json_overrides(
              python: optional_arg('values', json_type('number'), langs: json_langs(only: 'python')),
            ),
          )),
          optional_arg('python', json_type('number'), langs: json_langs(only: 'python')),
        ])
      }
      let(:klass) do
        Class.new do
          def awesome_calc(values: nil, python: nil)
          end
        end
      end

      it 'should generate a method with argument, without block' do
        is_expected.to include("def awesome_calc(python: nil, values: nil)\n")
      end
    end

    context 'with arguments size >= 4' do
      before {
        api_json_hogehoge['members'] << json_method('awesomeCalc', [
          required_arg('a', json_type('number')),
          optional_kwarg('options', [
            optional_arg('b', json_type('number'), langs: json_langs(only: %w(js java))),
            optional_arg('bOnlyForPython', json_type('number'), langs: json_langs(only: 'python')),
            optional_arg('c', json_type('number')),
            optional_arg('d', json_type('number')),
            optional_arg('e', json_type('number')),
          ])
        ])
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
        api_json_hogehoge['members'] << json_method('awesomeCalc')
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
        api_json_hogehoge['members'] << json_method('awesomeCalc', [
          required_arg('a', json_type('number')),
          optional_kwarg('options', [
            optional_arg('b', json_type('number'), langs: json_langs(only: %w(js java))),
            optional_arg('bOnlyForPython', json_type('number'), langs: json_langs(only: 'python')),
            optional_arg('c', json_type('number')),
          ])
        ])
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
        is_expected.to include("def awesome_calc(a, bOnlyForPython: nil, c: nil, &block)\n")
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

  describe 'alias for setter' do
    def result_arg(name)
      object_arg(name, [
        required_arg('x', json_type('int')),
        required_arg('y', json_type('int')),
      ], required: true)
    end

    before {
      api_json_hogehoge['members'] << json_method('setResult', [
        result_arg('result'),
      ], type: json_type('void'))
      api_json_hogehoge['members'] << json_method('setResults', [
        result_arg('result1'),
        result_arg('result2'),
      ], type: json_type('void'))
      api_json_hogehoge['members'] << json_method('setResultWithOpt', [
        result_arg('result'),
        optional_kwarg('options', [
          optional_arg('timeout', json_type('number')),
          optional_arg('threshold', json_type('number')),
        ]),
      ], type: json_type('void'))
    }
    let(:klass) do
      Class.new do
        def set_result(some_result)
          @result = some_result
        end

        def set_results(res1, res2)
          @result1 = res1
          @result2 = res2
        end

        def set_result_with_opt(result, timeout: nil, threshold: nil)
          @result = result
          @timeout = timeout
          @threshold = threshold
        end
      end
    end

    it 'should generate a setter method' do
      is_expected.to include("def set_result(result)\n")
      is_expected.to include("alias_method :result=, :set_result\n")
      is_expected.to include("def set_result_with_opt(result, timeout: nil, threshold: nil)\n")
      is_expected.to include("alias_method :result_with_opt=, :set_result_with_opt\n")
    end

    it 'should not generate a setter method for the methods with multiple parameters' do
      is_expected.to include("def set_results(result1, result2)\n")
      is_expected.not_to include("alias_method :results=")
    end
  end
end
