source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

# RX
pod 'RxSwift', '~> 2.1'
pod 'RxCocoa', '~> 2.1'

# logging
pod 'Fabric', '~> 1.6'
pod 'Crashlytics', '~> 3.6'
pod 'Mixpanel', '~> 2.9'
pod 'XCGLogger', '~> 3.0'

# google
pod 'GoogleMaps', '~> 1.10'
#pod 'GoogleSignIn', '~> 2.4'
pod 'FTGooglePlacesAPI'

# facebook
pod 'FBSDKCoreKit', '~> 4.7'
pod 'FBSDKLoginKit', '~> 4.7'
pod 'FBSDKShareKit', '~> 4.8'

# amazon
pod 'AWSS3', '~> 2.3'
pod 'AWSCognito', '~> 2.3'

# networking
pod 'Alamofire', '~> 3.1.0'
pod 'AlamofireObjectMapper', '~> 2.1'
pod 'ReachabilitySwift', '~> 2.3'

# security
pod 'KeychainAccess', '~> 2.3'

# validation
pod 'Validator', '~> 1.1'

#images
pod 'Kingfisher', '~> 1.8'
pod 'SDWebImage', '~> 3.7'
pod 'MWPhotoBrowser', '~> 2.1'

# serialization
pod 'Genome', '~> 2.0'
pod 'ObjectMapper', '~> 1.1'
pod 'HanekeSwift', '~> 0.10'
pod 'Freddy'

# ui controls
pod 'Material', '~> 1.29'
pod 'ResponsiveLabel', '~> 1.0'
pod 'MBProgressHUD', '~> 0.9.1'
pod 'SVProgressHUD'
pod 'SVPullToRefresh', '~> 0.4'
pod 'DAProgressOverlayView', '~> 1.0'
pod 'DWTagList', '~> 0.0'
pod 'SMCalloutView', '~> 2.1'
pod 'JSQMessagesViewController', '~> 7.2'
pod 'URBMediaFocusViewController', '~> 0.5'
pod 'MZFormSheetPresentationController', '~> 2.2'

def testing_pods
    pod 'Quick', '~> 0.8.0'
    pod 'Nimble', '3.0.0'
end

target "shoutit-iphoneTests" do
    testing_pods
end

target "shoutit-iphoneUITests" do
    testing_pods
end

# other
pod 'CryptoSwift'
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