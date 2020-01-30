#!/usr/bin/env ruby

def export_translations_and_strip_ignored
  Dir.chdir('..') do
    # This exports translations into xcloc folders inside the Localisations folder
    languages = Dir['Application/Resources/*.lproj']
      .map { |lproj| File.basename(lproj, '.lproj') }
      .delete_if { |lang| lang == 'Base' }
      .map { |lang| "-exportLanguage #{lang}"}
      .join(' ')
    project = Dir['*.xcodeproj'].first

    puts "Exporting localizations from #{project} to Localizations folder"
    sh "xcodebuild -exportLocalizations -localizationPath Localizations -project #{project} #{languages}"

    # Move all xliffs up
    Dir['Localizations/*.xcloc/**/*.xliff'].each { |xliff|
      target = "Localizations/#{File.basename(xliff)}"
      File.delete(target) if File.exists?(target)
      File.rename(xliff, target)
    }
    Dir['Localizations/*.xcloc'].each { |xcloc|
       FileUtils.remove_dir(xcloc)
    }

    # remove ignored strings
    Dir['Localizations/*.xliff'].each { |xliff|
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
end

def import_translations
  Dir.chdir('..') do
    project = Dir['*.xcodeproj'].first

    Dir['Localizations/*.xliff'].each { |xliff|
      sh "xcodebuild -importLocalizations -localizationPath #{xliff} -project #{project}"
    }
  end
end

# work around empty lines issue (REXML bug)
def doc_by_stripping_empty_lines(doc)
  output = ""

  doc.write(output)
  doc = REXML::Document.new(output)
  REXML::XPath.match(doc, "//body/text()").each { |body|
    body.value = body.value.sub(/(\n +)+(\n *)/m, '\2')
  }

  doc
end
