#
# Be sure to run `pod lib lint AkuminaLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AkuminaAuthiOSLib'
  s.version          = '0.1.75'
  s.summary          = 'iOS Auth Library for Akumina App'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://akuminadev.visualstudio.com/DefaultCollection/Akumina/_git/MobileDev-iOS-PoC'
  # s.s creenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Akumina' => 'anburaj.pandi@akumina.com' }
  s.source           = { :git => 'https://github.com/akumina/auth-ios-lib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.swift_version = "5.8"
  s.source_files = '**/Classes/**/*.{h,m,swift}'
  s.resource = 'ms-intune-app-sdk-ios/IntuneMAMResources.bundle'
  # s.resource_bundles = {
  #   'AkuminaLib' => ['AkuminaLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.frameworks = 'Rollbar'
   s.dependency 'MSAL'
   # s.dependency 'Rollbar'
   s.vendored_frameworks = 'ms-intune-app-sdk-ios/IntuneMAMSwift.xcframework', 'ms-intune-app-sdk-ios/IntuneMAMSwiftStub.xcframework'
end
