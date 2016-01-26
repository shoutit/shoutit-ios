source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Alamofire', '~> 3.1.0'
pod 'XCGLogger', '~> 3.0'
pod 'SwiftyJSON', '~> 2.3.1'
pod 'MBProgressHUD', '~> 0.9.1'
pod 'Kingfisher', '~> 1.8'
pod 'SVPullToRefresh', '~> 0.4'
pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git'
pod 'GoogleSignIn', '~> 2.4'
pod 'Mixpanel', '~> 2.9'
pod 'ObjectMapper', '~> 1.0'
pod 'AlamofireObjectMapper', '~> 2.0'
pod 'CryptoSwift'
pod 'SVProgressHUD'
pod 'FBSDKCoreKit', '~> 4.7'
pod 'FBSDKLoginKit', '~> 4.7'
pod 'GoogleMaps', '~> 1.10'
pod 'Fabric'
pod 'Crashlytics'
pod 'DWTagList', '~> 0.0'
pod 'SMCalloutView', '~> 2.1'
pod 'SDWebImage', '~> 3.7'
pod 'MWPhotoBrowser', '~> 2.1'
pod 'FBSDKShareKit', '~> 4.8'
pod 'ReachabilitySwift', '~> 2.3'
pod 'AWSS3', '~> 2.3'
pod 'AWSCognito', '~> 2.3'
pod 'JSQMessagesViewController', '~> 7.2'
pod 'URBMediaFocusViewController', '~> 0.5'
pod 'libPusher', '~> 1.6'
pod 'DAProgressOverlayView', '~> 1.0'
pod 'MK', '~> 1.0'
pod 'MZFormSheetPresentationController', '~> 2.2'

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