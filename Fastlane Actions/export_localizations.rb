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
        post_process_xliffs(destination_path)
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

      # post process files
      def self.post_process_xliffs(destination_path)
        Dir["#{destination_path}/*.xliff"].each { |xliff|
          puts "Cleaning up '#{xliff}'"

          doc = REXML::Document.new(File.new(xliff))

          set_source_to_devel(doc)
          doc = remove_ignored_strings(doc)
          doc.context[:attribute_quote] = :quote

          File.open(xliff, 'w') { |file|
            formatter = OrderedAttributesFormatter.new
            formatter.write(doc, file)
          }
        }
      end

      # modify source language to `en_devel`
      def self.set_source_to_devel(doc)
        REXML::XPath.each(doc, "//file") { |e|
          e.attributes['source-language'] = 'en_devel'
        }
      end

      # remove ignored strings (bartycrouch)
      def self.remove_ignored_strings(doc)
        REXML::XPath.match(doc, "//trans-unit[note[contains(.,'#bc-ignore!')]]").each(&:remove)

        # Strip empty lines
        # work around empty lines issue (REXML bug)
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

class OrderedAttributesFormatter < REXML::Formatters::Default
  def write_element(node, output)
    if node.expanded_name == 'xliff'
      write_xliff_element(node, output)
    else
      super(node, output)
    end
  end

  # override so we can sort xliff node attributes like weblate
  def write_xliff_element(node, output)
    output << "<#{node.expanded_name}"

    weblate_order = ['xmlns', 'xsi', 'schemaLocation', 'version']

    node.attributes.to_a.map { |a|
      Hash === a ? a.values : a
    }.flatten.sort_by {|attr| weblate_order.index(attr.name) }.each do |attr|
      output << " "
      attr.write( output )
    end unless node.attributes.empty?

    if node.children.empty?
      output << "/"
    else
      output << ">"
      node.children.each { |child|
        write( child, output )
      }
      output << "</#{node.expanded_name}"
    end
    output << ">"
  end
end
