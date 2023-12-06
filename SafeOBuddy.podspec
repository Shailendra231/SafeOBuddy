#
#  Be sure to run `pod spec lint SafeOBuddy.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "SafeOBuddy"
  spec.version      = "1.0.1"
  spec.summary      = "It is a custom framework of Safeobuddy"
  spec.description  = "It is a custom framework of Safeobuddy. This sdk is for digital locks"

  spec.homepage     = "https://github.com/Shailendra231/SafeOBuddy"
  spec.license      = "MIT"

  spec.author      = { "Shailendra Kumar Ram" => "ramkumarshailendra@gmail.com" }

  spec.platform     = :ios, "12"

  spec.source       = { :git => "https://github.com/Shailendra231/SafeOBuddy.git", :tag => "1.0.1" }

  spec.static_framework = true

  spec.source_files  = "SafeOBuddy/**/*"

  spec.dependency "TTLock"
  
  # spec.framework  = "TTLockFramework"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

end