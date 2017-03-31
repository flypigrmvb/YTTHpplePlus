#
# Be sure to run `pod lib lint YTTHpplePlus.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YTTHpplePlus'
  s.version          = '0.1.0'
  s.summary          = 'Lightweight And Powerful XML/HTML Parser Util'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Lightweight And Powerful XML/HTML Parser Util
                       DESC

  s.homepage         = 'https://github.com/flypigrmvb/YTTHpplePlus'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'flypigrmvb' => '862709539@qq.com' }
  s.source           = { :git => 'https://github.com/flypigrmvb/YTTHpplePlus.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YTTHpplePlus/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YTTHpplePlus' => ['YTTHpplePlus/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
    s.library = 'xml2'
    s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
    s.requires_arc = true
    s.module_name = "YTTHpplePlus"

end
