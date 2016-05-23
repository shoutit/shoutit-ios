source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/twilio/cocoapod-specs'

platform :ios, '8.1'
use_frameworks!

# Twilio
pod 'TwilioConversationsClient', '~>0.24.0'

# RX
pod 'RxSwift', '~> 2.3.1'
pod 'RxCocoa', '~> 2.3.1'

# logging
pod 'Fabric', '~> 1.6'
pod 'Crashlytics', '~> 3.6'
pod 'Mixpanel', '~> 2.9'
pod 'SwiftyBeaver'

# google
pod 'GoogleMaps', '~> 1.10'
pod 'FTGooglePlacesAPI'
pod 'GooglePlaces', :git => 'https://github.com/piotrbernad/Swift-Google-Maps-API'

# facebook
pod 'FBSDKCoreKit', '~> 4.7'
pod 'FBSDKLoginKit', '~> 4.7'
pod 'FBSDKShareKit', '~> 4.8'

# amazon
pod 'AWSS3', '~> 2.3'
pod 'AWSCognito', '~> 2.3'
pod 'AmazonS3RequestManager'

# networking
pod 'Alamofire', '~> 3.3.0'
pod 'ReachabilitySwift', '~> 2.3'
pod 'Timberjack'

# security
pod 'KeychainAccess', '~> 2.3'

# validation
pod 'Validator', '~> 1.1'

#images
pod 'Kingfisher', '~> 2.2'
pod 'SDWebImage', '~> 3.7'
pod "MWPhotoBrowser", :path => "MWPhotoBrowser/"
pod 'MBMapSnapshotter'
pod 'LLVideoEditor', '~> 1.0'

# serialization
pod 'Argo'
pod 'Curry', '< 2.0'
pod 'Ogra'

# ui controls
pod 'Material', '~> 1.39'
pod 'ResponsiveLabel', '~> 1.0'
pod 'MBProgressHUD', '~> 0.9.1'
pod 'SVProgressHUD'
pod 'SVPullToRefresh', '~> 0.4'
pod 'DAProgressOverlayView', '~> 1.0'
pod 'DZNEmptyDataSet'
pod 'ACPDownload', '~> 1.1.0'
pod 'SlackTextViewController'

pod 'UIViewAppearanceSwift', :git => 'https://github.com/levantAJ/UIViewAppearanceSwift.git', :commit => '2ba05f14a8c1a7eb16b1525ac325962516d6992a'

# other
pod 'libPusher', '~> 1.6'

# After every installation, copy the license and settings plists over to our project
post_install do |installer|
  require 'fileutils'

  acknowledgements_plist = 'Pods/Target Support Files/Pods/Pods-Acknowledgements.plist'
  if Dir.exists?('Floc/Resources/Settings.bundle') && File.exists?(acknowledgements_plist)
    FileUtils.cp(acknowledgements_plist, 'Floc/Resources/Settings.bundle/Acknowledgements.plist')
  end
  
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
          config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
          config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      end
  end
end