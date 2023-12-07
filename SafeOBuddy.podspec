#
#  Be sure to run `pod spec lint SafeOBuddy.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "SafeOBuddy"
  s.version      = "1.0.3"
  s.summary      = "It is a custom framework of Safeobuddy"
  s.description  = "It is a custom framework of Safeobuddy. This sdk is for digital locks"

  s.homepage     = "https://github.com/Shailendra231/SafeOBuddy"

  s.license      = "MIT"

  s.author      = { "Shailendra Kumar Ram" => "ramkumarshailendra@gmail.com" }

  s.platform     = :ios, "12.0"
  s.swift_versions = "5.0"

  s.source       = { :git => "https://github.com/Shailendra231/SafeOBuddy.git", :tag => "1.0.3" }

  s.static_framework = true

  s.source_files  = "SafeOBuddy/**/*"

  s.dependency "TTLock"
  
  # spec.framework  = "TTLockFramework"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

end