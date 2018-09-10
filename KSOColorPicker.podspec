#
#  Be sure to run `pod spec lint KSOColorPicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "KSOColorPicker"
  s.version      = "0.1.0"
  s.summary      = "KSOColorPicker is a iOS framework to facilitate picking colors by the user."
  s.description  = <<-DESC
  KSOColorPicker is a iOS framework to facilitate picking colors by the user. It supports WA, RGB, and HSBA modes. It supports drag and drop on all compatible iOS devices.
                   DESC
                   
  s.homepage     = "https://github.com/Kosoku/KSOColorPicker"
  s.license      = { :type => "BSD", :file => "LICENSE.txt" }
  s.author       = { "William Towe" => "willbur1984@gmail.com" }
  s.source       = { :git => "https://github.com/Kosoku/KSOColorPicker.git", :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.requires_arc = true

  s.source_files  = "KSOColorPicker/**/*.{h,m}"
  s.exclude_files = "KSOColorPicker/KSOColorPicker-Info.h"
  s.private_header_files = "KSOColorPicker/Private/*.h"

  s.resource_bundles = {
    'KSOColorPicker' => ['KSOColorPicker/**/*.{lproj}']
  }

  s.frameworks = "Foundation", "UIKit"

  s.dependency "Ditko"
  s.dependency "Stanley"
end
