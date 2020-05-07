#
# Be sure to run `pod lib lint Appear.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Appear'
  s.version          = '0.1.14'
  s.summary          = 'Create AR apps with dynamic content'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A framework that makes it super easy to use dynamic Augmented Reality content in your app. Access content uploaded to the Appear Console Webpage in your iOS app.
                       DESC

  s.homepage         = 'https://github.com/purplos/appear-ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Purpl AS' => 'hei@purpl.no' }
  s.source           = { :git => 'https://github.com/purplos/appear-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.3'

  s.source_files = 'Appear/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Appear' => ['Appear/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', 'ARKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
