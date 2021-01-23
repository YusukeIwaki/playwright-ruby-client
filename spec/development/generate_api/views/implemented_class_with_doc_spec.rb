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

  describe 'implemented and documented method' do
    context 'without arguments' do
      before {
        api_json_hogehoge['members'] << {
          'kind' => 'method',
          'langs' => {},
          'name' => 'awesomeCalc',
          'type' => { 'name' => 'number' },
          'required' => true,
          'args' => [],
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
        api_json_hogehoge['members'] << {
          'kind' => 'method',
          'langs' => {},
          'name' => 'awesomeCalc',
          'type' => { 'name' => 'number' },
          'required' => true,
          'args' => [
            {
              'kind' => 'property',
              'langs' => {},
              'name' => 'a',
              'type' => { 'name' => 'number' },
              'required' => true,
            },
            {
              'kind' => 'property',
              'langs' => {},
              'name' => 'options',
              'type' => {
                'name' => 'Object',
                'properties' => [
                  {
                    'kind' => 'property',
                    'langs' => {
                      'only' => ['js'],
                    },
                    'name' => 'b',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {
                      'only' => ['python'],
                    },
                    'name' => 'bOnlyForPython',
                    'type' => { 'name' => 'number' },
                    'required' => true,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {},
                    'name' => 'c',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                ],
              },
              'required' => false,
            },
          ],
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
        api_json_hogehoge['members'] << {
          'kind' => 'method',
          'langs' => {},
          'name' => 'awesomeCalc',
          'type' => { 'name' => 'number' },
          'required' => true,
          'args' => [
            {
              'kind' => 'property',
              'langs' => {},
              'name' => 'a',
              'type' => { 'name' => 'number' },
              'required' => true,
            },
            {
              'kind' => 'property',
              'langs' => {},
              'name' => 'options',
              'type' => {
                'name' => 'Object',
                'properties' => [
                  {
                    'kind' => 'property',
                    'langs' => {
                      'only' => ['js'],
                    },
                    'name' => 'b',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {
                      'only' => ['python'],
                    },
                    'name' => 'bOnlyForPython',
                    'type' => { 'name' => 'number' },
                    'required' => true,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {},
                    'name' => 'c',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {},
                    'name' => 'd',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {},
                    'name' => 'e',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                ],
              },
              'required' => false,
            },
          ],
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
        api_json_hogehoge['members'] << {
          'kind' => 'method',
          'langs' => {},
          'name' => 'awesomeCalc',
          'type' => { 'name' => 'number' },
          'required' => true,
          'args' => [],
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
        api_json_hogehoge['members'] << {
          'kind' => 'method',
          'langs' => {},
          'name' => 'awesomeCalc',
          'type' => { 'name' => 'number' },
          'required' => true,
          'args' => [
            {
              'kind' => 'property',
              'langs' => {},
              'name' => 'a',
              'type' => { 'name' => 'number' },
              'required' => true,
            },
            {
              'kind' => 'property',
              'langs' => {},
              'name' => 'options',
              'type' => {
                'name' => 'Object',
                'properties' => [
                  {
                    'kind' => 'property',
                    'langs' => {
                      'only' => ['js'],
                    },
                    'name' => 'b',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {
                      'only' => ['python'],
                    },
                    'name' => 'bOnlyForPython',
                    'type' => { 'name' => 'number' },
                    'required' => true,
                  },
                  {
                    'kind' => 'property',
                    'langs' => {},
                    'name' => 'c',
                    'type' => { 'name' => 'number' },
                    'required' => false,
                  },
                ],
              },
              'required' => false,
            },
          ],
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

  describe 'alias for setter' do
    def result_arg(name)
      {
        "kind" => "property",
        "langs" => {},
        "name" => name,
        "type" => {
          "name" => "Object",
          "properties" => [
            {
              "kind" => "property",
              "langs" => {},
              "name" => "x",
              "type" => {
                "name" => "int",
                "expression" => "[int]"
              },
              "required" => true,
            },
            {
              "kind" => "property",
              "langs" => {},
              "name" => "y",
              "type" => {
                "name" => "int",
                "expression" => "[int]"
              },
              "required" => true,
            }
          ],
          "expression" => "[Object]"
        },
        "required" => true,
        "comment" => "",
      }
    end

    def optional_arg(arg_name, *properties)
      {
        'kind' => 'property',
        'langs' => {},
        'name' => arg_name.to_s,
        'type' => {
          'name' => 'Object',
          'properties' => properties.map do |name|
            {
              'kind' => 'property',
              'langs' => {},
              'name' => name.to_s,
              'type' => { 'name' => 'number' },
              'required' => false,
            }
          end
        },
        'required' => false,
      }
    end

    before {
      api_json_hogehoge['members'] << {
        'kind' => 'method',
        "langs" => {},
        "name" => "setResult",
        "type" => { "name" => "void" },
        "required" => true,
        "args" => [ result_arg('result') ],
      }
      api_json_hogehoge['members'] << {
        'kind' => 'method',
        "langs" => {},
        "name" => "setResults",
        "type" => { "name" => "void" },
        "required" => true,
        "args" => [ result_arg('result1'), result_arg('result2') ],
      }
      api_json_hogehoge['members'] << {
        'kind' => 'method',
        "langs" => {},
        "name" => "setResultWithOpt",
        "type" => { "name" => "void" },
        "required" => true,
        "args" => [ result_arg('result'), optional_arg('options', :timeout, :threshold) ],
      }
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
