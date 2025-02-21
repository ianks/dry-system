<!--- DO NOT EDIT THIS FILE - IT'S AUTOMATICALLY GENERATED VIA DEVTOOLS --->

## 0.21.0 2021-11-01


### Added

- Added **component dir namespaces** as a way to specify multiple, ordered, independent namespace rules within a given component dir. This replaces and expands upon the namespace support we previously provided via the singular `default_namespace` component dir setting (@timriley in #181)

### Changed

- `default_namespace` setting on component dirs has been deprecated. Add a component dir namespace instead, e.g. instead of:

  ```ruby
  # Inside Dry::System::Container.configure
  config.component_dirs.add "lib" do |dir|
    dir.default_namespace = "admin"
  end
  ```

  Add this:

  ```ruby
  config.component_dirs.add "lib" do |dir|
    dir.namespaces.add "admin", key: nil
  end
  ```

  (@timriley in #181)
- `Dry::System::Component#path` has been removed and replaced by `Component#require_path` and `Component#const_path` (@timriley in #181)
- Unused `Dry::System::FileNotFoundError` and `Dry::System::InvalidComponentIdentifierTypeError` errors have been removed (@timriley in #194)
- Allow bootsnap for Rubies up to 3.0.x (via #196) (@pusewicz)

[Compare v0.21.0...v0.21.0](https://github.com/dry-rb/dry-system/compare/v0.21.0...v0.21.0)

## 0.21.0 2021-11-01


### Added

- Added **component dir namespaces** as a way to specify multiple, ordered, independent namespace rules within a given component dir. This replaces and expands upon the namespace support we previously provided via the singular `default_namespace` component dir setting (@timriley in #181)

### Changed

- `default_namespace` setting on component dirs has been deprecated. Add a component dir namespace instead, e.g. instead of:

  ```ruby
  # Inside Dry::System::Container.configure
  config.component_dirs.add "lib" do |dir|
    dir.default_namespace = "admin"
  end
  ```

  Add this:

  ```ruby
  config.component_dirs.add "lib" do |dir|
    dir.namespaces.add "admin", key: nil
  end
  ```

  (@timriley in #181)
- `Dry::System::Component#path` has been removed and replaced by `Component#require_path` and `Component#const_path` (@timriley in #181)
- Unused `Dry::System::FileNotFoundError` and `Dry::System::InvalidComponentIdentifierTypeError` errors have been removed (@timriley in #194)
- Allow bootsnap for Rubies up to 3.0.x (via #196) (@pusewicz)

[Compare v0.20.0...v0.21.0](https://github.com/dry-rb/dry-system/compare/v0.20.0...v0.21.0)

## 0.20.0 2021-09-12


### Fixed

- Fixed dependency graph plugin to work with internal changes introduced in 0.19.0 (@wuarmin in #173)
- Fixed behavior of `Dry::System::Identifier#start_with?` for components identified by a single segment, or if all matching segments are provided (@wuarmin in #177)
- Fixed compatibility of `finalize!` signature provided in `Container::Stubs` (@mpokrywka in #178)

### Changed

- [internal] Upgraded to new `setting` API provided in dry-configurable 0.13.0 (@timriley in #179)

[Compare v0.19.2...v0.20.0](https://github.com/dry-rb/dry-system/compare/v0.19.2...v0.20.0)

## 0.19.2 2021-08-30


### Changed

- [internal] Improved compatibility with upcoming dry-configurable 0.13.0 release (@timriley in #186)

[Compare v0.18.2...v0.19.2](https://github.com/dry-rb/dry-system/compare/v0.18.2...v0.19.2)

## 0.18.2 2021-08-30


### Changed

- [internal] Improved compatibility with upcoming dry-configurable 0.13.0 release (@timriley in #187)

[Compare v0.19.1...v0.18.2](https://github.com/dry-rb/dry-system/compare/v0.19.1...v0.18.2)

## 0.19.1 2021-07-11


### Fixed

- Check for registered components (@timriley in #175)


[Compare v0.19.0...v0.19.1](https://github.com/dry-rb/dry-system/compare/v0.19.0...v0.19.1)

## 0.19.0 2021-04-22

This release marks a huge step forward for dry-system, bringing support for Zeitwerk and other autoloaders, plus clearer configuration and improved consistency around component resolution for both finalized and lazy loading containers. [Read the announcement post](https://dry-rb.org/news/2021/04/22/dry-system-0-19-released-with-zeitwerk-support-and-more-leading-the-way-for-hanami-2-0/) for a high-level tour of the new features.

### Added

- New `component_dirs` setting on `Dry::System::Container`, which must be used for specifying the directories which dry-system will search for component source files.

  Each added component dir is relative to the container's `root`, and can have its own set of settings configured:

  ```ruby
  class MyApp::Container < Dry::System::Container
    configure do |config|
      config.root = __dir__

      # Defaults for all component dirs can be configured separately
      config.component_dirs.auto_register = true # default is already true

      # Component dirs can be added and configured independently
      config.component_dirs.add "lib" do |dir|
        dir.add_to_load_path = true # defaults to true
        dir.default_namespace = "my_app"
      end

      # All component dir settings are optional. Component dirs relying on default
      # settings can be added like so:
      config.component_dirs.add "custom_components"
    end
  end
  ```

  The following settings are available for configuring added `component_dirs`:

  - `auto_register`, a boolean, or a proc accepting a `Dry::System::Component` instance and returning a truthy or falsey value. Providing a proc allows an auto-registration policy to apply on a per-component basis
  - `add_to_load_path`, a boolean
  - `default_namespace`, a string representing the leading namespace segments to be stripped from the component's identifier (given the identifier is derived from the component's fully qualified class name)
  - `loader`, a custom replacement for the default `Dry::System::Loader` to be used for the component dir
  - `memoize`, a boolean, to enable/disable memoizing all components in the directory, or a proc accepting a `Dry::System::Component` instance and returning a truthy or falsey value. Providing a proc allows a memoization policy to apply on a per-component basis

  _All component dir settings are optional._

  (@timriley in #155, #157, and #162)
- A new autoloading-friendly `Dry::System::Loader::Autoloading` is available, which is tested to work with [Zeitwerk](https://github.com/fxn/zeitwerk) 🎉

  Configure this on the container (via a component dir `loader` setting), and the loader will no longer `require` any components, instead allowing missing constant resolution to trigger the loading of the required file.

  This loader presumes an autoloading system like Zeitwerk has already been enabled and appropriately configured.

  A recommended setup is as follows:

  ```ruby
  require "dry/system/container"
  require "dry/system/loader/autoloading"
  require "zeitwerk"

  class MyApp::Container < Dry::System::Container
    configure do |config|
      config.root = __dir__

      config.component_dirs.loader = Dry::System::Loader::Autoloading
      config.component_dirs.add_to_load_path = false

      config.component_dirs.add "lib" do |dir|
        # ...
      end
    end
  end

  loader = Zeitwerk::Loader.new
  loader.push_dir MyApp::Container.config.root.join("lib").realpath
  loader.setup
  ```

  (@timriley in #153)
- [BREAKING] `Dry::System::Component` instances (which users of dry-system will interact with via custom loaders, as well as via the `auto_register` and `memoize` component dir settings described above) now return a `Dry::System::Identifier` from their `#identifier` method. The raw identifier string may be accessed via the identifier's own `#key` or `#to_s` methods. `Identifier` also provides a helpful namespace-aware `#start_with?` method for returning whether the identifier begins with the provided namespace(s) (@timriley in #158)

### Changed

- Components with `# auto_register: false` magic comments in their source files are now properly ignored when lazy loading (@timriley in #155)
- `# memoize: true` and `# memoize: false` magic comments at top of component files are now respected (@timriley in #155)
- [BREAKING] `Dry::System::Container.load_paths!` has been renamed to `.add_to_load_path!`. This method now exists as a mere convenience only. Calling this method is no longer required for any configured `component_dirs`; these are now added to the load path automatically (@timriley in #153 and #155)
- [BREAKING] `auto_register` container setting has been removed. Configured directories to be auto-registered by adding `component_dirs` instead (@timriley in #155)
- [BREAKING] `default_namespace` container setting has been removed. Set it when adding `component_dirs` instead (@timriley in #155)
- [BREAKING] `loader` container setting has been nested under `component_dirs`, now available as `component_dirs.loader` to configure a default loader for all component dirs, as well as on individual component dirs when being added (@timriley in #162)
- [BREAKING] `Dry::System::ComponentLoadError` is no longer raised when a component could not be lazy loaded; this was only raised in a single specific failure condition. Instead, a `Dry::Container::Error` is raised in all cases of components failing to load (@timriley in #155)
- [BREAKING] `Dry::System::Container.auto_register!` has been removed. Configure `component_dirs` instead. (@timriley in #157)
- [BREAKING] The `Dry::System::Loader` interface has changed. It is now a static interface, no longer initialized with a component. The component is instead passed to each method as an argument: `.require!(component)`, `.call(component, *args)`, `.constant(component)` (@timriley in #157)
- [BREAKING] `Dry::System::Container.require_path` has been removed. Provide custom require behavior by configuring your own `loader` (@timriley in #153)

[Compare v0.18.1...v0.19.0](https://github.com/dry-rb/dry-system/compare/v0.18.1...v0.19.0)

## 0.18.1 2020-08-26


### Fixed

- Made `Booter#boot_files` a public method again, since it was required by dry-rails (@timriley)


[Compare v0.18.0...v0.18.1](https://github.com/dry-rb/dry-system/compare/v0.18.0...v0.18.1)

## 0.18.0 2020-08-24


### Added

- New `bootable_dirs` setting on `Dry::System::Container`, which accepts paths to multiple directories for looking up bootable component files. (@timriley in PR #151)

  For each entry in the `bootable_dirs` array, relative directories will be appended to the container's `root`, and absolute directories will be left unchanged.

  When searching for bootable files, the first match will win, and any subsequent same-named files will not be loaded. In this way, the `bootable_dirs` act similarly to the `$PATH` in a shell environment.


[Compare v0.17.0...v0.18.0](https://github.com/dry-rb/dry-system/compare/v0.17.0...v0.18.0)

## 0.17.0 2020-02-19


### Fixed

- Works with the latest dry-configurable version (issue #141) (@solnic)

### Changed

- Depends on dry-configurable `=> 0.11.1` now (@solnic)

[Compare v0.16.0...v0.17.0](https://github.com/dry-rb/dry-system/compare/v0.16.0...v0.17.0)

## 0.16.0 2020-02-15


### Changed

- Plugins can now define their own settings which are available in the `before(:configure)` hook (@solnic)
- Dependency on dry-configurable was bumped to `~> 0.11` (@solnic)

[Compare v0.15.0...v0.16.0](https://github.com/dry-rb/dry-system/compare/v0.15.0...v0.16.0)

## 0.15.0 2020-01-30


### Added

- New hook - `before(:configure)` which a plugin should use if it needs to declare new settings (@solnic)

```ruby
# in your plugin code
before(:configure) { setting :my_new_setting }

after(:configure) { config.my_new_setting = "awesome" }
```


### Changed

- Centralize error definitions in `lib/dry/system/errors.rb` (@cgeorgii)
- All built-in plugins use `before(:configure)` now to declare their settings (@solnic)

[Compare v0.14.1...v0.15.0](https://github.com/dry-rb/dry-system/compare/v0.14.1...v0.15.0)

## 0.14.1 2020-01-22


### Changed

- Use `Kernel.require` explicitly to avoid issues with monkey-patched `require` from ActiveSupport (@solnic)

[Compare v0.14.0...v0.14.1](https://github.com/dry-rb/dry-system/compare/v0.14.0...v0.14.1)

## 0.14.0 2020-01-21


### Fixed

- Misspelled plugin name raises meaningful error (issue #132) (@cgeorgii)
- Fail fast if auto_registrar config contains incorrect path (@cutalion)


[Compare v0.13.2...v0.14.0](https://github.com/dry-rb/dry-system/compare/v0.13.2...v0.14.0)

## 0.13.2 2019-12-28


### Fixed

- More keyword warnings (flash-gordon)


[Compare v0.13.1...v0.13.2](https://github.com/dry-rb/dry-system/compare/v0.13.1...v0.13.2)

## 0.13.1 2019-11-07


### Fixed

- Fixed keyword warnings reported by Ruby 2.7 (flash-gordon)
- Duplicates in `Dry::System::Plugins.loaded_dependencies` (AMHOL)


[Compare v0.13.0...v0.13.1](https://github.com/dry-rb/dry-system/compare/v0.13.0...v0.13.1)

## 0.13.0 2019-10-13


### Added

- `Container.resolve` accepts and optional block parameter which will be called if component cannot be found. This makes dry-system consistent with dry-container 0.7.2 (flash-gordon)
  ```ruby
  App.resolve('missing.dep') { :fallback } # => :fallback
  ```

### Changed

- [BREAKING] `Container.key?` triggers lazy-loading for not finalized containers. If component wasn't found it returns `false` without raising an error. This is a breaking change, if you seek the previous behavior, use `Container.registered?` (flash-gordon)

[Compare v0.12.0...v0.13.0](https://github.com/dry-rb/dry-system/compare/v0.12.0...v0.13.0)

## 0.12.0 2019-04-24


### Changed

- Compatibility with dry-struct 1.0 and dry-types 1.0 (flash-gordon)

[Compare v0.11.0...v0.12.0](https://github.com/dry-rb/dry-system/compare/v0.11.0...v0.12.0)

## 0.11.0 2019-03-22


### Changed

- [BREAKING] `:decorate` plugin was moved from dry-system to dry-container (available in 0.7.0+). To upgrade remove `use :decorate` and change `decorate` calls from `decorate(key, decorator: something)` to `decorate(key, with: something)` (flash-gordon)
- [internal] Compatibility with dry-struct 0.7.0 and dry-types 0.15.0

[Compare v0.10.1...v0.11.0](https://github.com/dry-rb/dry-system/compare/v0.10.1...v0.11.0)

## 0.10.1 2018-07-05


### Added

- Support for stopping bootable components with `Container.stop(component_name)` (GustavoCaso)

### Fixed

- When using a non-finalized container, you can now resolve multiple different container objects registered using the same root key as a bootable component (timriley)


[Compare v0.10.0...v0.10.1](https://github.com/dry-rb/dry-system/compare/v0.10.0...v0.10.1)

## 0.10.0 2018-06-07


### Added

- You can now set a custom inflector on the container level. As a result, the `Loader`'s constructor accepts two arguments: `path` and `inflector`, update your custom loaders accordingly (flash-gordon)

  ```ruby
  class MyContainer < Dry::System::Container
    configure do |config|
      config.inflector = Dry::Inflector.new do |inflections|
        inflections.acronym('API')
      end
    end
  end
  ```

### Changed

- A helpful error will be raised if an invalid setting value is provided (GustavoCaso)
- When using setting plugin, will use default values from types (GustavoCaso)
- Minimal supported ruby version was bumped to `2.3` (flash-gordon)
- `dry-struct` was updated to `~> 0.5` (flash-gordon)

[Compare v0.9.2...v0.10.0](https://github.com/dry-rb/dry-system/compare/v0.9.2...v0.10.0)

## 0.9.2 2018-02-08


### Fixed

- Default namespace no longer breaks resolving dependencies with identifier that includes part of the namespace (ie `mail.mailer`) (GustavoCaso)


[Compare v0.9.1...v0.9.2](https://github.com/dry-rb/dry-system/compare/v0.9.1...v0.9.2)

## 0.9.1 2018-01-03


### Fixed

- Plugin dependencies are now auto-required and a meaningful error is raised when a dep failed to load (solnic)


[Compare v0.9.0...v0.9.1](https://github.com/dry-rb/dry-system/compare/v0.9.0...v0.9.1)

## 0.9.0 2018-01-02


### Added

- Plugin API (solnic)
- `:env` plugin which adds support for setting `env` config value (solnic)
- `:logging` plugin which adds a default logger (solnic)
- `:decorate` plugin for decorating registered objects (solnic)
- `:notifications` plugin adding pub/sub bus to containers (solnic)
- `:monitoring` plugin which adds `monitor` method for monitoring object method calls (solnic)
- `:bootsnap` plugin which adds support for bootsnap (solnic)

### Changed

- [BREAKING] renamed `Container.{require=>require_from_root}` (GustavoCaso)

[Compare v0.8.1...v0.9.0](https://github.com/dry-rb/dry-system/compare/v0.8.1...v0.9.0)

## 0.8.1 2017-10-17


### Fixed

- Aliasing an external component works correctly (solnic)
- Manually calling `:init` will also finalize a component (solnic)


[Compare v0.8.0...v0.8.1](https://github.com/dry-rb/dry-system/compare/v0.8.0...v0.8.1)

## 0.8.0 2017-10-16


### Added

- Support for external bootable components (solnic)
- Built-in `:system` components including `:settings` component (solnic)

### Fixed

- Lazy-loading components work when a container has `default_namespace` configured (GustavoCaso)

### Changed

- [BREAKING] Improved boot DSL with support for namespacing and lifecycle before/after callbacks (solnic)

[Compare v0.7.3...v0.8.0](https://github.com/dry-rb/dry-system/compare/v0.7.3...v0.8.0)

## 0.7.3 2017-08-02


### Fixed

- `Container.enable_stubs!` calls super too, which actually adds `stub` API (solnic)
- Issues with lazy-loading and import in stub mode are gone (solnic)


[Compare v0.7.2...v0.7.3](https://github.com/dry-rb/dry-system/compare/v0.7.2...v0.7.3)

## 0.7.2 2017-08-02


### Added

- `Container.enable_stubs!` for test environments which enables stubbing components (GustavoCaso)

### Changed

- Component identifiers can now include same name more than once ie `foo.stuff.foo` (GustavoCaso)
- `Container#boot!` was renamed to `Container#start` (davydovanton)
- `Container#boot` was renamed to `Container#init` (davydovanton)

[Compare v0.7.1...v0.7.2](https://github.com/dry-rb/dry-system/compare/v0.7.1...v0.7.2)

## 0.7.1 2017-06-16


### Changed

- Accept string values for Container's `root` config (timriley)

[Compare v0.7.0...v0.7.1](https://github.com/dry-rb/dry-system/compare/v0.7.0...v0.7.1)

## 0.7.0 2017-06-15


### Added

- Added `manual_registrar` container setting (along with default `ManualRegistrar` implementation), and `registrations_dir` setting. These provide support for a well-established place for keeping files with manual container registrations (timriley)
- AutoRegistrar parses initial lines of Ruby source files for "magic comments" when auto-registering components. An `# auto_register: false` magic comment will prevent a Ruby file from being auto-registered (timriley)
- `Container.auto_register!`, when called with a block, yields a configuration object to control the auto-registration behavior for that path, with support for configuring 2 different aspects of auto-registration behavior (both optional):

  ```ruby
  class MyContainer < Dry::System::Container
    auto_register!('lib') do |config|
      config.instance do |component|
        # custom logic for initializing a component
      end

      config.exclude do |component|
        # return true to skip auto-registration of the component, e.g.
        # component.path =~ /entities/
      end
    end
  end
  ```
- A helpful error will be raised if a bootable component's finalize block name doesn't match its boot file name (GustavoCaso)

### Changed

- The `default_namespace` container setting now supports multi-level namespaces (GustavoCaso)
- `Container.auto_register!` yields a configuration block instead of a block for returning a custom instance (see above) (GustavoCaso)
- `Container.import` now requires an explicit local name for the imported container (e.g. `import(local_name: AnotherContainer)`) (timriley)

[Compare v0.6.0...v0.7.0](https://github.com/dry-rb/dry-system/compare/v0.6.0...v0.7.0)

## 0.6.0 2016-02-02


### Changed

- Lazy load components as they are resolved, rather than on injection (timriley)
- Perform registration even though component already required (blelump)

[Compare v0.5.1...v0.6.0](https://github.com/dry-rb/dry-system/compare/v0.5.1...v0.6.0)

## 0.5.1 2016-08-23


### Fixed

- Undefined locals or method calls will raise proper exceptions in Lifecycle DSL (aradunovic)


[Compare v0.5.0...v0.5.1](https://github.com/dry-rb/dry-system/compare/v0.5.0...v0.5.1)

## 0.5.0 2016-08-15

for multi-container setups. As part of this release `dry-system` has been renamed to `dry-system`.

### Added

- Boot DSL with:
  - Lifecycle triggers: `init`, `start` and `stop` (solnic)
  - `use` method which auto-boots a dependency and makes it available in the booting context (solnic)
- When a component relies on a bootable component, and is being loaded in isolation, the component will be booted automatically (solnic)

### Changed

- [BREAKING] `Dry::Component::Container` is now `Dry::System::Container` (solnic)
- [BREAKING] Configurable `loader` is now a class that accepts container's config and responds to `#constant` and `#instance` (solnic)
- [BREAKING] `core_dir` renameda to `system_dir` and defaults to `system` (solnic)
- [BREAKING] `auto_register!` yields `Component` objects (solnic)

[Compare v0.4.3...v0.5.0](https://github.com/dry-rb/dry-system/compare/v0.4.3...v0.5.0)

## 0.4.3 2016-08-01


### Fixed

- Return immediately from `Container.load_component` if the requested component key already exists in the container. This fixes a crash when requesting to load a manually registered component with a name that doesn't map to a filename (timriley in [#24](https://github.com/dry-rb/dry-system/pull/24))


[Compare v0.4.2...v0.4.3](https://github.com/dry-rb/dry-system/compare/v0.4.2...v0.4.3)

## 0.4.2 2016-07-26


### Fixed

- Ensure file components can be loaded when they're requested for the first time using their shorthand container identifier (i.e. with the container's default namespace removed) (timriley)


[Compare v0.4.1...v0.4.2](https://github.com/dry-rb/dry-system/compare/v0.4.1...v0.4.2)

## 0.4.1 2016-07-26


### Fixed

- Require the 0.4.0 release of dry-auto_inject for the features below (in 0.4.0) to work properly (timriley)


[Compare v0.4.0...v0.4.1](https://github.com/dry-rb/dry-system/compare/v0.4.0...v0.4.1)

## 0.4.0 2016-07-26


### Added

- Support for supplying a default namespace to a container, which is passed to the container's injector to allow for convenient shorthand access to registered objects in the same namespace (timriley in [#20](https://github.com/dry-rb/dry-system/pull/20))

  ```ruby
  # Set up container with default namespace
  module Admin
    class Container < Dry::Component::Container
      configure do |config|
        config.root = Pathname.new(__dir__).join("../..")
        config.default_namespace = "admin"
      end
    end

    Import = Container.injector
  end

  module Admin
    class CreateUser
      # "users.repository" will resolve an Admin::Users::Repository instance,
      # where previously you had to identify it as "admin.users.repository"
      include Admin::Import["users.repository"]
    end
  end
  ```
- Support for supplying to options directly to dry-auto_inject's `Builder` via `Dry::Component::Container#injector(options)`. This allows you to provide dry-auto_inject customizations like your own container of injection strategies (timriley in [#20](https://github.com/dry-rb/dry-system/pull/20))
- Support for accessing all available injector strategies, not just the defaults (e.g. `MyContainer.injector.some_custom_strategy`) (timriley in [#19](https://github.com/dry-rb/dry-system/pull/19))

### Changed

- Subclasses of `Dry::Component::Container` no longer have an `Injector` constant automatically defined within them. The recommended approach is to save your own injector object to a constant, which allows you to pass options to it at the same time, e.g. `MyApp::Import = MyApp::Container.injector(my_options)` (timriley in [#19](https://github.com/dry-rb/dry-system/pull/19))

[Compare v0.3.0...v0.4.0](https://github.com/dry-rb/dry-system/compare/v0.3.0...v0.4.0)

## 0.3.0 2016-06-18

Removed two pieces that are moving to dry-web:

### Changed

- Removed two pieces that are moving to dry-web:
- Removed `env` setting from `Container` (timriley)
- Removed `Dry::Component::Config` and `options` setting from `Container` (timriley)
- Changed `Component#configure` behavior so it can be run multiple times for configuration to be applied in multiple passes (timriley)

[Compare v0.2.0...v0.3.0](https://github.com/dry-rb/dry-system/compare/v0.2.0...v0.3.0)

## 0.2.0 2016-06-13


### Fixed

- Fixed bug where specified auto-inject strategies were not respected (timriley)

### Changed

- Component core directory is now `component/` by default (timriley)
- Injector default stragegy is now whatever dry-auto_inject's default is (rather than hard-coding a particular default strategy for dry-system) (timriley)

[Compare v0.1.0...v0.2.0](https://github.com/dry-rb/dry-system/compare/v0.1.0...v0.2.0)

## 0.1.0 2016-06-07


### Added

- Provide a dependency injector as an `Inject` constant inside any subclass of `Dry::Component::Container`. This injector supports all of `dry-auto_inject`'s default injection strategies, and will lazily load any dependencies as they are injected. It also supports arbitrarily switching strategies, so they can be used in different classes as required (e.g. `include MyComponent::Inject.args["dep"]`) (timriley)
- Support aliased dependency names when calling the injector object (e.g. `MyComponent::Inject[foo: "my_app.foo", bar: "another.thing"]`) (timriley)
- Allow a custom dependency loader to be set on a container via its config (AMHOL)

  ```ruby
  class MyContainer < Dry::Component::Container
    configure do |config|
      # other config
      config.loader = MyLoader
    end
  end
  ```

### Changed

- `Container.boot` now only makes a simple `require` for the boot file (solnic)
- Container object is passed to `Container.finalize` blocks (solnic)
- Allow `Pathname` objects passed to `Container.require` (solnic)
- Support lazily loading missing dependencies from imported containers (solnic)
- `Container.import_module` renamed to `.injector` (timriley)
- Default injection strategy is now `kwargs`, courtesy of the new dry-auto_inject default (timriley)

[Compare v0.0.2...v0.1.0](https://github.com/dry-rb/dry-system/compare/v0.0.2...v0.1.0)

## 0.0.2 2015-12-24


### Added

- Containers have a `name` setting (solnic)
- Containers can be imported into one another (solnic)

### Changed

- Container name is used to determine the name of its config file (solnic)

[Compare v0.0.1...v0.0.2](https://github.com/dry-rb/dry-system/compare/v0.0.1...v0.0.2)

## 0.0.1 2015-12-24

First public release, extracted from rodakase project
