use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'Wumi' do

    pod 'AFNetworking', '~> 3.0.4'
    
    pod 'NHAlignmentFlowLayout'
    
    pod 'BTNavigationDropdownMenu', :git => 'https://github.com/PhamBaTho/BTNavigationDropdownMenu.git', :branch => 'swift-2.3'

    pod 'SWRevealViewController'

    pod 'SDWebImage'

    pod 'FMDB'

    pod 'JSBadgeView'

    pod 'DateTools'

    pod 'CYLDeallocBlockExecutor'
    
    pod 'CTAssetsPickerController', '~>3.3.0'
    
    pod 'KIImagePager'

    pod 'FormatterKit'
    
    pod 'DGActivityIndicatorView'
    
    pod 'Kanna', '~> 1.1.0'
    
    #pod 'ReachabilitySwift'
    
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    
    pod 'TTTAttributedLabel'
    
    pod 'WeiboSDK', :git => 'https://github.com/sinaweibosdk/weibo_ios_sdk.git'
    
    pod 'FBSDKCoreKit'
    
    pod 'FBSDKShareKit'
    
    pod 'FBSDKLoginKit'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
