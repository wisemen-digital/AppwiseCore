#!/usr/bin/env ruby

# To fix integration of interface builder with pre-compiled pods,
# we need to add all swift files to the public headers
def interface_builder_integration(installer)
  installer.pods_project.targets.each do |target|
    next unless target.respond_to?(:product_type)
    next unless target.product_type == 'com.apple.product-type.framework'

    target.source_build_phase.files_references.each do |file|
      next unless File.extname(file.path) == '.swift'

      buildFile = target.headers_build_phase.add_file_reference(file)
      buildFile.settings = { 'ATTRIBUTES' => ['Public']}
    end
  end

  installer.pods_project.save
end

# Force enable bitcode for projects
def force_bitcode(installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
    end
  end

  installer.pods_project.save
end

# Generate the project using xcodegen (and take into account pre-compiled Rome frameworks)
def generate_project(installer)
  generate_dependencies(installer)

  # Try to generate project
  unless system('which xcodegen > /dev/null')
    abort 'XcodeGen is not installed. Visit https://github.com/yonaskolb/XcodeGen to learn more.'
  end

  system('xcodegen')
  fix_project(installer)
end

############ Private methods ############

# Generate the project dependencies file, adding frameworks to the right targets
# and also checking if they are linked dynamically or not.
def generate_dependencies(installer)
  File.open('projectDependencies.yml', 'w') { |file|
    file.puts 'targets:'

    installer.umbrella_targets
      .each { |target|
        target_name = target.cocoapods_target_label.sub(/^Pods-/, '')
        file.puts "  #{target_name}:"
        file.puts "    dependencies:"

        target.specs
          .map { |spec| spec.parent || spec }
          .uniq
          .sort_by { |spec| spec.name }
          .select { |spec| framework_exists? spec }
          .each { |spec|
            file.puts "      - framework: #{framework_path(spec)}"
            file.puts "        embed: #{framework_dynamic? spec}"
          }
      }
  }
end

# Fix xcodegen issue (duplicate "Supporting Files" definition)
def fix_project(installer)
  Dir.glob('*.xcodeproj/project.pbxproj').each do |f|
    regex = /(children = \(\s+?\w+? \/\* Sources \*\/,\s+?\w+? \/\* Resources \*\/,\n)\s+?\w+? \/\* Supporting Files \*\/,\n(\s+?\))/m

    contents = File.read(f)
      .gsub(regex, '\1\2')

    File.open(f, "w") { |file| file.puts contents }
  end
end

# Convert a pod name to a valid swift module name
def module_name(spec)
  spec.module_name || name.gsub(/^([0-9])/, '_\1').gsub(/[^a-zA-Z0-9_]/, '_')
end

# Path to the framework (when using rome)
def framework_path(spec)
  "Rome/#{module_name(spec)}.framework"
end

def framework_exists?(spec)
  File.directory? framework_path(spec)
end

def framework_dynamic?(spec)
  binary = "#{framework_path(spec)}/#{module_name(spec)}"
  !%x(file #{binary} | grep universal | grep dynamic).to_s.strip.empty?
end
