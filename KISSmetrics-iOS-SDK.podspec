#
# Be sure to run `pod lib lint KISSmetrics-iOS-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KISSmetrics-iOS-SDK'
  s.module_name      = 'Kissmetrics'
  s.version          = '2.5.0b'
  s.summary          = 'iOS SDK for KISSmetrics'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://www.kissmetrics.io'
  s.license          = { :type => 'Apache 2.0', :text => 'http://www.apache.org/licenses/LICENSE-2.0.txt' }
  s.author           = { 'kissmetrics' => 'support@kissmetrics.io' }
  s.source           = { :git => 'https://github.com/kissmetrics/KISSmetrics-iOS-SDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'KISSmetrics-iOS-SDK/Classes/**/*'
  
end
