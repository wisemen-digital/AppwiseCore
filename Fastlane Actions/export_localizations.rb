#!/usr/bin/env ruby

require 'tmpdir'
require_relative 'lib/OrderedAttributesFormatter'

module Fastlane
  module Actions
    class ExportLocalizationsAction < Action
      def self.run(params)
        resources_path = params[:resources_path]
        destination_path = params[:destination_path]
        project = params[:project] || Dir['*.xcodeproj'].first
        unless project
          UI.user_error!('Unable to find Xcode project in folder')
        end

        Dir.mktmpdir do |tmpdir|
          export_xliffs(project, resources_path, tmpdir)
          post_process_xliffs(tmpdir, destination_path)
        end
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
        sh %Q(xcodebuild -exportLocalizations -localizationPath "#{destination_path}" -project "#{project}" #{languages})

        # Move all xliffs up
        Dir["#{destination_path}/*.xcloc/**/*.xliff"].each { |xliff|
          target = "#{destination_path}/#{File.basename(xliff)}"
          File.delete(target) if File.exists?(target)
          File.rename(xliff, target)
        }
      end

      # post process files
      def self.post_process_xliffs(source_path, destination_path)
        Dir["#{source_path}/*.xliff"].each { |source_xliff|
          puts "Post-processing '#{File.basename source_xliff}'"

          source_doc = REXML::Document.new(File.new(source_xliff))
          set_source_to_devel(source_doc)
          source_doc = remove_ignored_strings(source_doc)

          destination_xliff = "#{destination_path}/#{File.basename source_xliff}"
          if File.file?(destination_xliff)
            destination_doc = REXML::Document.new(File.new(destination_xliff))
            merge_status_fields(source_doc, destination_doc)
          end

          source_doc.context[:attribute_quote] = :quote

          File.open(destination_xliff, 'w') { |file|
            formatter = OrderedAttributesFormatter.new
            formatter.write(source_doc, file)
          }
        }
      end

      # modify source language to `en_devel`
      def self.set_source_to_devel(doc)
        REXML::XPath.each(doc, '//file') { |e|
          e.attributes['source-language'] = 'en_devel'
        }
      end

      # remove ignored strings (bartycrouch)
      def self.remove_ignored_strings(doc)
        REXML::XPath.match(doc, "//trans-unit[note[contains(.,'#bc-ignore!')]]").each(&:remove)
        REXML::XPath.match(doc, "//trans-unit[source[contains(.,'#bc-ignore!')]]").each(&:remove)

        # Strip empty lines
        # work around empty lines issue (REXML bug)
        output = ''
        doc.write(output)
        doc = REXML::Document.new(output)
        REXML::XPath.match(doc, '//body/text()').each { |body|
          body.value = body.value.sub(/(\n +)+(\n *)/m, '\2')
        }

        doc
      end

      # merge status fields
      def self.merge_status_fields(a, b)
        REXML::XPath.each(a, '//file') { |file|
          correspondingFile = REXML::XPath.first(b, "//file[@original='#{file.attributes['original']}']/body")
          next if correspondingFile.nil?
          mappedUnits = correspondingFile.elements.to_a.map { |x| [x.attributes['id'], x] }.to_h

          file.each_element('//trans-unit') { |unit|
            correspondingUnit = mappedUnits[unit.attributes['id']]
            next if correspondingUnit.nil?

            unit.add_attribute(
              'approved',
              correspondingUnit.attributes['approved']
            ) unless correspondingUnit.attributes['approved'].nil?

            next if unit.elements['target'].nil?
            next if correspondingUnit.elements['target'].nil?
            unit.elements['target'].add_attribute(
              'state',
              correspondingUnit.elements['target'].attributes['state']
            ) unless correspondingUnit.elements['target'].attributes['state'].nil?
          }
        }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Export app localizations'
      end

      def self.details
        'Export app localizations with help of xcodebuild -exportLocalizations tool'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :resources_path,
                               description: 'Resources path where .lproj are located',
                             default_value: 'Application/Resources',
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :destination_path,
                               description: 'Destination path where XLIFF will be exported to',
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
