Pod::Spec.new do |s|
  s.name = 'KISSmetrics-iOS-SDK'
  s.version = '2.0.1'
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.summary = 'iOS SDK for KISSmetrics.'
  s.homepage = 'http://www.kissmetrics.com'
  s.authors = { 'kissmetrics' => 'support@kissmetrics.com' }
  s.source = { :git => 'https://github.com/kissmetrics/KISSmetrics-iOS-SDK.git', :tag => "v#{s.version}", :submodules => true }

  s.platform = :ios, '5.1'

  s.public_header_files = 'KISSmetricsAPI/KISSmetricsAPI.h'
  s.source_files = 'KISSmetricsAPI/*.{c,h,m}'

  s.requires_arc = true
end
