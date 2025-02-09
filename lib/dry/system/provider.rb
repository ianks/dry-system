# frozen_string_literal: true

require "concurrent/map"
require "dry/system/constants"
require "dry/system/components/bootable"

module Dry
  module System
    class Provider
      attr_reader :name

      attr_reader :options

      attr_reader :components

      def initialize(name, options)
        @name = name
        @options = options
        @components = Concurrent::Map.new
      end

      def boot_path
        options.fetch(:boot_path)
      end

      def boot_files
        ::Dir[boot_path.join("**/#{RB_GLOB}")].sort
      end

      def register_component(name, fn)
        components[name] = Components::Bootable.new(name, &fn)
      end

      def boot_file(name)
        boot_files.detect { |path| Pathname(path).basename(RB_EXT).to_s == name.to_s }
      end

      def component(component_name, options = {})
        component_key = options[:key] || component_name
        components.fetch(component_key).new(component_name, options)
      end

      def load_components
        boot_files.each { |f| Kernel.require f }
        freeze
        self
      end
    end
  end
end
