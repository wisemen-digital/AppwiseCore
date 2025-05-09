Pod::Spec.new do |s|
	# info
	s.name = 'AppwiseCore'
	s.version = '2.1.1'
	s.summary = 'Just a library of some stuff we use internally.'
	s.description = <<-DESC
	Contains a few generic types (appdelegate, config, router, client) and some helper methods.
	DESC
	s.homepage = 'https://github.com/appwise-labs/AppwiseCore'
	s.authors = {
		'David Jennes' => 'david.jennes@gmail.com'
	}
	s.license = {
		:type => 'MIT',
		:file => 'LICENSE'
	}
	s.ios.deployment_target = '12.0'
	s.swift_version = '5.10'

	# files
	s.source = {
		:git => 'https://github.com/appwise-labs/AppwiseCore.git',
		:tag => s.version,
		:submodules => true
	}
	s.preserve_paths = ['Scripts/*', 'Sourcery/*', 'SwiftGen/*', 'XcodeGen/*', 'Fastlane Actions/*']
	s.default_subspec = 'Core', 'Behaviours', 'UI', 'UIApplication'

	# VC behaviours
	s.subspec 'Behaviours' do |ss|
		ss.source_files = 'Sources/Behaviours/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Common'
		ss.dependency 'Then', '~> 3.0'
	end

	# Common files
	s.subspec 'Common' do |ss|
		ss.source_files = 'Sources/Common/**/*.swift'
		ss.pod_target_xcconfig = {
			'SWIFT_ACTIVE_COMPILATION_CONDITIONS[config=Debug]' => 'DEBUG'
		}
	end

	# core spec
	s.subspec 'Core' do |ss|
		ss.source_files = 'Sources/Core/**/*.swift'
		ss.resource_bundles = {
			'AppwiseCore-Core' => ['Resources/Core/*.lproj', 'Resources/Core/PrivacyInfo.xcprivacy']
		}

		# dependencies
		ss.dependency 'AppwiseCore/Common'
		ss.dependency 'Alamofire', '> 5.10'
		ss.dependency 'CocoaLumberjack/Swift', '~> 3.8'
		ss.dependency 'Sentry', '~> 8.40'
		ss.dependency 'Then', '~> 3.0'
	end

	# coredata
	s.subspec 'CoreData' do |ss|
		ss.source_files = 'Sources/CoreData/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Common'
		ss.dependency 'AppwiseCore/Core'
		ss.dependency 'Groot', '~> 3.0'
	end

	# deeplinking
	s.subspec 'DeepLink' do |ss|
		ss.source_files = 'Sources/DeepLink/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Behaviours'
		ss.dependency 'AppwiseCore/Common'
	end

	# UI
	s.subspec 'UI' do |ss|
		ss.source_files = 'Sources/UI/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Core'
		ss.dependency 'AppwiseCore/Behaviours'
		ss.dependency 'IBAnimatable', '~> 6.1'
	end

	# UIApplication
	s.subspec 'UIApplication' do |ss|
		ss.source_files = 'Sources/UIApplication/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Core'
	end
end
