# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    # Default manual registration implementation
    #
    # This is currently configured by default for every System::Container.
    # Manual registrar objects are responsible for loading files from configured
    # manual registration paths, which should hold code to explicitly register
    # certain objects with the container.
    #
    # @api private
    class ManualRegistrar
      attr_reader :container

      attr_reader :config

      def initialize(container)
        @container = container
        @config = container.config
      end

      # @api private
      def finalize!
        ::Dir[registrations_dir.join(RB_GLOB)].sort.each do |file|
          call(File.basename(file, RB_EXT))
        end
      end

      # @api private
      def call(component)
        require(root.join(config.registrations_dir, component.root_key.to_s))
      end

      def file_exists?(component)
        File.exist?(File.join(registrations_dir, "#{component.root_key}#{RB_EXT}"))
      end

      private

      # @api private
      def registrations_dir
        root.join(config.registrations_dir)
      end

      # @api private
      def root
        container.root
      end
    end
  end
end
