Pod::Spec.new do |s|
	# info
	s.name = 'AppwiseCore'
	s.version = '0.9.0'
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
	s.ios.deployment_target = '9.0'
	s.swift_version = '4.2'
	
	# files
	s.source = {
		:git => 'https://github.com/appwise-labs/AppwiseCore.git',
		:tag => s.version,
		:submodules => true
	}
	s.preserve_paths = ['Scripts/*', 'Sourcery/*']
	s.default_subspec = 'Core', 'Behaviours', 'UI'
	
	# core spec
	s.subspec 'Core' do |ss|
		ss.source_files = 'Sources/Core/**/*.swift'
		ss.pod_target_xcconfig = {
			'SWIFT_ACTIVE_COMPILATION_CONDITIONS[config=Debug]' => 'DEBUG'
		}
		
		# dependencies
		ss.dependency 'Alamofire'
		ss.dependency 'CocoaLumberjack/Swift'
		ss.dependency 'CrashlyticsRecorder'
		ss.dependency 'Then'
	end

	# VC behaviours
	s.subspec 'Behaviours' do |ss|
		ss.source_files = 'Sources/Behaviours/**/*.swift'

		# dependencies
		ss.dependency 'Then'
	end
	
	# coredata
	s.subspec 'CoreData' do |ss|
		ss.source_files = 'Sources/CoreData/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Core'
		ss.dependency 'Groot'
		ss.dependency 'SugarRecord/CoreData'
	end

	# deeplinking
	s.subspec 'DeepLink' do |ss|
		ss.source_files = 'Sources/DeepLink/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Behaviours'
	end
	
	# UI
	s.subspec 'UI' do |ss|
		ss.source_files = 'Sources/UI/**/*.swift'
		
		# dependencies
		ss.dependency 'AppwiseCore/Core'
		ss.dependency 'AppwiseCore/Behaviours'
		ss.dependency 'IBAnimatable'
	end
end
