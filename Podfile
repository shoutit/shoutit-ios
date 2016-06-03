source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/twilio/cocoapod-specs'

platform :ios, '8.1'
use_frameworks!

target 'shoutit' do

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

#deeplinks
pod 'DeepLinkKit', '~> 1.2.1'

pod 'UIViewAppearanceSwift', :git => 'https://github.com/levantAJ/UIViewAppearanceSwift.git', :commit => '2ba05f14a8c1a7eb16b1525ac325962516d6992a'

# other
pod 'libPusher', '~> 1.6'

#contacts
pod 'ContactsPicker'

  target "shoutitTests" do
    inherit! :search_paths
    pod 'Quick', '~> 0.9'
    pod 'Nimble', '~> 4.0'
    pod 'RxNimble', '~> 0.2'
  end
end

# After every installation, copy the license and settings plists over to our project
post_install do |installer|
  require 'fileutils'
  
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
          config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
          config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
          config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
  end
end