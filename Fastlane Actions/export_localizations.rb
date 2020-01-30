#!/usr/bin/env ruby

module Fastlane
  module Actions
    class ExportLocalizationsAction < Action
      def self.run(params)
        resources_path = params[:resources_path]
        destination_path = params[:destination_path]
        project = params[:project] || Dir['*.xcodeproj'].first
        unless project
          UI.user_error!("Unable to find Xcode project in folder")
        end

        export_xliffs(project, resources_path, destination_path)
        remove_ignored_strings(destination_path)
      end

      # export localizations from project
      def self.export_xliffs(project, resources_path, destination_path)
        # This exports translations into xcloc folders inside the Localisations folder
        languages = Dir["#{resources_path}/*.lproj"]
          .map { |lproj| File.basename(lproj, '.lproj') }
          .delete_if { |lang| lang == 'Base' }
          .map { |lang| "-exportLanguage #{lang}"}
          .join(' ')

        puts "Exporting localizations from #{project} to #{destination_path} folder"
        puts Dir.pwd
        sh "xcodebuild -exportLocalizations -localizationPath \"#{destination_path}\" -project \"#{project}\" #{languages}"

        # Move all xliffs up
        Dir["#{destination_path}/*.xcloc/**/*.xliff"].each { |xliff|
          target = "#{destination_path}/#{File.basename(xliff)}"
          File.delete(target) if File.exists?(target)
          File.rename(xliff, target)
        }
        Dir["#{destination_path}/*.xcloc"].each { |xcloc|
           FileUtils.remove_dir(xcloc)
        }
      end

      # remove ignored strings (bartycrouch)
      def self.remove_ignored_strings(destination_path)
        Dir["#{destination_path}/*.xliff"].each { |xliff|
          puts "Cleaning up '#{xliff}'"

          doc = REXML::Document.new(File.new(xliff))

          REXML::XPath.match(doc, "//trans-unit[note[contains(.,'#bc-ignore!')]]").each(&:remove)
          doc = doc_by_stripping_empty_lines(doc)
          doc.context[:attribute_quote] = :quote

          File.open(xliff, 'w') { |file|
            doc.write(:output => file)
          }
        }
      end

      # work around empty lines issue (REXML bug)
      def self.doc_by_stripping_empty_lines(doc)
        output = ""

        doc.write(output)
        doc = REXML::Document.new(output)
        REXML::XPath.match(doc, "//body/text()").each { |body|
          body.value = body.value.sub(/(\n +)+(\n *)/m, '\2')
        }

        doc
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set commits of a release"
      end

      def self.details
        "Export app localizations with help of xcodebuild -exportLocalizations tool"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :resources_path,
                               description: "Resources path where .lproj are located",
                             default_value: 'Application/Resources',
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :destination_path,
                                  env_name: "DESTINATION_PATH",
                               description: "Destination path where XLIFF will be exported to",
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
