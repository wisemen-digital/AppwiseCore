#!/usr/bin/env ruby

require 'tmpdir'
require_relative 'lib/OrderedAttributesFormatter'

module Fastlane
  module Actions
    class ImportLocalizationsAction < Action
      def self.run(params)
        source_path = params[:source_path]
        project = params[:project] || Dir['*.xcodeproj'].first
        unless project
          UI.user_error!('Unable to find Xcode project in folder')
        end

        Dir.mktmpdir do |tmpdir|
          pre_process_xliffs(source_path, tmpdir)
          import_xliffs(project, tmpdir)
          post_process_import()
        end
      end

      # pre-process xliffs
      def self.pre_process_xliffs(source_path, destination_path)
        Dir["#{source_path}/*.xliff"].each { |source_xliff|
          puts "Pre-processing '#{File.basename source_xliff}'"

          destination_xliff = "#{destination_path}/#{File.basename source_xliff}"
          doc = REXML::Document.new(File.new(source_xliff))

          set_source_to_en(doc)
          doc.context[:attribute_quote] = :quote

          File.open(destination_xliff, 'w') { |file|
            formatter = OrderedAttributesFormatter.new
            formatter.write(doc, file)
          }
        }
      end

      # import localizations from project
      def self.import_xliffs(project, source_path)
        Dir["#{source_path}/*.xliff"].each { |xliff|
          sh %Q(xcodebuild -importLocalizations -localizationPath "#{xliff}" -project "#{project}")
        }
      end

      # post-process import
      def self.post_process_import()
        bartycrouch = './Pods/BartyCrouch/bartycrouch'

        if File.file?(bartycrouch)
          puts 'Normalize strings files...'
          system('./Pods/BartyCrouch/bartycrouch update -x')
        end
      end

      # modify source language to `en`
      def self.set_source_to_en(doc)
        REXML::XPath.each(doc, '//file') { |e|
          e.attributes['source-language'] = 'en'
        }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Import app localizations'
      end

      def self.details
        'Import app localizations with help of xcodebuild -importLocalizations tool'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :source_path,
                               description: 'Path where .xliff files are located',
                             default_value: 'Localizations',
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :project,
                                  env_name: 'PROJECT',
                               description: 'Project to export localizations from',
                                  optional: true,
                                      type: String)
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ['djbe']
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
