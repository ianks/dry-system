require 'dry/system/container'

RSpec.describe Dry::System::Container, '.auto_register!' do
  context 'standard loader' do
    before do
      class Test::Container < Dry::System::Container
        configure do |config|
          config.root = SPEC_ROOT.join('fixtures').realpath
        end

        load_paths!('components')
        auto_register!('components')
      end
    end

    it { expect(Test::Container['foo']).to be_an_instance_of(Foo) }
    it { expect(Test::Container['bar']).to be_an_instance_of(Bar) }
    it { expect(Test::Container['bar.baz']).to be_an_instance_of(Bar::Baz) }
  end

  context 'standard loader with a default namespace configured' do
    before do
      class Test::Container < Dry::System::Container
        configure do |config|
          config.root = SPEC_ROOT.join('fixtures').realpath
          config.default_namespace = 'namespaced'
        end

        load_paths!('namespaced_components')
        auto_register!('namespaced_components')
      end
    end

    specify { expect(Test::Container['bar']).to be_a(Namespaced::Bar) }
    specify { expect(Test::Container['bar'].foo).to be_a(Namespaced::Foo) }
    specify { expect(Test::Container['foo']).to be_a(Namespaced::Foo) }
  end

  context 'with a custom loader' do
    before do
      class Test::Loader < Dry::System::Loader
        class Component < Dry::System::Component
          def identifier
            super + ".yay"
          end

          def instance(*args)
            constant.respond_to?(:call) ? constant : constant.new(*args)
          end
        end

        def load(system_path)
          Component.new(system_path, options)
        end
      end

      class Test::Container < Dry::System::Container
        configure do |config|
          config.root = SPEC_ROOT.join('fixtures').realpath
          config.loader = ::Test::Loader
        end

        load_paths!('components')
        auto_register!('components')
      end
    end

    it { expect(Test::Container['foo.yay']).to be_an_instance_of(Foo) }
    it { expect(Test::Container['bar.yay']).to eq(Bar) }
    it { expect(Test::Container['bar.yay'].call).to eq("Welcome to my Moe's Tavern!") }
    it { expect(Test::Container['bar.baz.yay']).to be_an_instance_of(Bar::Baz) }
  end
end
