#!/usr/bin/env ruby

module Fastlane
  module Actions
    class ImportLocalizationsAction < Action
      def self.run(params)
        source_path = params[:source_path]
        project = params[:project] || Dir['*.xcodeproj'].first
        unless project
          UI.user_error!("Unable to find Xcode project in folder")
        end

        import_xliffs(project, source_path)
      end

      # import localizations from project
      def self.import_xliffs(project, source_path)
        Dir["#{source_path}/*.xliff"].each { |xliff|
          sh "xcodebuild -importLocalizations -localizationPath #{xliff} -project #{project}"
        }

        # trigger BartyCrouch to keep diffs minimal
        bartycrouch = './Pods/BartyCrouch/bartycrouch'
        if File.file?(bartycrouch)
          puts 'Normalize strings files...'
          system('./Pods/BartyCrouch/bartycrouch update -x')
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set commits of a release"
      end

      def self.details
        "Import app localizations with help of xcodebuild -importLocalizations tool"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :source_path,
                               description: "Path where .xliff files are located",
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
