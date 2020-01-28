#!/usr/bin/env ruby

def export_translations_and_strip_ignored
  # This exports translations into xcloc folders inside the Localisations folder
  export_localizations(
    destination_path: 'Localizations',
    project: Dir['*.xcodeproj', base: '..'].first
  )

  # Move all xliffs up
  Dir.chdir('..') do
    Dir['Localizations/*.xcloc/**/*.xliff'].each { |xliff|
      target = "Localizations/#{File.basename(xliff)}"
      File.delete(target) if File.exists?(target)
      File.rename(xliff, target)
    }
    Dir['Localizations/*.xcloc'].each { |xcloc|
       FileUtils.remove_dir(xcloc)
    }
  end

  # remove ignored strings
  Dir.chdir('..') do
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
  Dir['Localizations/*.xliff', base: '..'].each { |xliff|
    import_localizations(
      source_path: xliff,
      project: Dir['*.xcodeproj', base: '..'].first
    )
  }
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
