#!/usr/bin/env ruby

require 'tmpdir'

module Fastlane
  module Actions
    class SyncLocalizationsAction < Action
      def self.run(params)
        resources_path = params[:resources_path]
        xliff_path = params[:xliff_path]
        project = params[:project] || Dir['*.xcodeproj'].first
        unless project
          UI.user_error!('Unable to find Xcode project in folder')
        end

        # try to import first
        ImportLocalizationsAction.run(
          source_path: xliff_path,
          project: project
        )

        # then export
        ExportLocalizationsAction.run(
          resources_path: resources_path,
          destination_path: xliff_path,
          project: project
        )
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Synchronise the language files"
      end

      def self.details
        "Invokes the import then the export action"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :resources_path,
                               description: "Resources path where .lproj are located",
                             default_value: 'Application/Resources',
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :xliff_path,
                               description: "Path where XLIFF are located (or will be exported to)",
                             default_value: 'Localizations',
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :project,
                                  env_name: "PROJECT",
                               description: "Project to export localizations from",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["djbe"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
