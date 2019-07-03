#
# Be sure to run `pod lib lint Cloudipsp.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = "Cloudipsp"
  s.version          = "0.4.2"
  s.summary          = "Library for accepting payments directly from iOS application's clients."

  s.homepage         = "https://github.com/cloudipsp/ios-sdk"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Maxim Kozenko" => "max.dnu@gmail.com" }
  s.source           = { :git => "https://github.com/cloudipsp/ios-sdk.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.resources	= 'Pod/Classes/**/*.xib'
  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'PassKit'
end
