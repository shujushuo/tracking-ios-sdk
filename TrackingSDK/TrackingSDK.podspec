Pod::Spec.new do |s|
    s.name             = 'TrackingSDK'
    s.version          = '0.2.1'
    s.summary          = 'A tracking SDK for iOS applications.'
    
    s.description      = <<-DESC
                         TrackingSDK is a framework that provides event tracking capabilities for iOS applications.
                         DESC
    
    s.homepage         = 'https://github.com/shujushuo/tracking-ios-sdk'
    s.license          = { :type => "Apache License, Version 2.0", :file => "../LICENSE" }
    s.author           = { "jiangzhenxing" => "jiangzhx@gmail.com" }
    s.source           = { :git => 'https://github.com/shujushuo/tracking-ios-sdk.git', :branch => 'main' }
    s.platform         = :ios, '10.0'
    
    # 确保路径正确，且有对应的文件
    s.source_files     = 'TrackingSDK/**/*.{h,m}'
    s.requires_arc     = true
    
    # 指定 ReachabilitySwift 的版本，确保支持 iOS 10.0
    s.dependency 'Reachability', '~> 3.2.0'
    s.dependency 'FMDB', '~> 2.7'

    s.frameworks = 'AdSupport'
    s.vendored_frameworks = 'TrackingSDK.framework'

  end
