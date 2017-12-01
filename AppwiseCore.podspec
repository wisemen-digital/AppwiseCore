Pod::Spec.new do |s|
	# info
	s.name = 'AppwiseCore'
	s.version = '0.5.0'
	s.summary = 'Just a library of some stuff we use internally.'
	s.description = <<-DESC
	Contains a few generic types (appdelegate, config, router, client) and some helper methods.
	DESC
	s.homepage = 'https://github.com/djbe/AppwiseCore'
	s.authors = {
		'David Jennes' => 'david.jennes@gmail.com'
	}
	s.license = {
		:type => 'MIT',
		:file => 'LICENSE'
	}
	s.ios.deployment_target = '9.0'
	
	# files
	s.source = {
		:git => 'https://github.com/djbe/AppwiseCore.git',
		:tag => s.version
	}
	s.default_subspec = 'Core', 'Behaviours', 'UI'
	
	# core spec
	s.subspec 'Core' do |ss|
		ss.source_files = 'Source/Core/**/*.swift'
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
		ss.source_files = 'Source/Behaviours/**/*.swift'
	end
	
	# coredata
	s.subspec 'CoreData' do |ss|
		ss.source_files = 'Source/CoreData/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Core'
		ss.dependency 'SugarRecord/CoreData'
		ss.dependency 'AlamofireCoreData'
	end

	# deeplinking
	s.subspec 'DeepLink' do |ss|
		ss.source_files = 'Source/DeepLink/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Behaviours'
	end
	
	# UI
	s.subspec 'UI' do |ss|
		ss.source_files = 'Source/UI/**/*.swift'
		
		# dependencies
		ss.dependency 'AppwiseCore/Core'
		ss.dependency 'IBAnimatable'
	end
end
