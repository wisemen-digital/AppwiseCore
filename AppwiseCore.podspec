Pod::Spec.new do |s|
	# info
	s.name = 'AppwiseCore'
	s.version = '0.3.0'
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
	s.default_subspec = 'Core', 'UI'
	
	# core spec
	s.subspec 'Core' do |ss|
		ss.source_files = 'Source/Core/**/*.swift'
		#ss.resource_bundles = {
		#	'Appwise' => ['Resources/*.lproj']
		#}
		ss.pod_target_xcconfig = {
			'SWIFT_ACTIVE_COMPILATION_CONDITIONS[config=Debug]' => 'DEBUG'
		}
		
		# dependencies
		ss.dependency 'Alamofire'
		ss.dependency 'AsyncSwift'
		ss.dependency 'CocoaLumberjack/Swift'
		ss.dependency 'CrashlyticsRecorder'
		ss.dependency 'Then'
	end
	
	# coredata
	s.subspec 'CoreData' do |ss|
		ss.source_files = 'Source/CoreData/**/*.swift'

		# dependencies
		ss.dependency 'AppwiseCore/Core'
		ss.dependency 'SugarRecord/CoreData'
		ss.dependency 'AlamofireCoreData'
	end
	
	# UI
	s.subspec 'UI' do |ss|
		ss.source_files = 'Source/UI/**/*.swift'
		
		# dependencies
		ss.dependency 'AppwiseCore/Core'
	end
end
