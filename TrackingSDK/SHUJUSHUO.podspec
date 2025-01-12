Pod::Spec.new do |s|
  s.name             = 'SHUJUSHUO'
  s.version          = '0.2.1'
  s.summary          = 'A tracking SDK for iOS applications.'
  
  s.description      = <<-DESC
                       TrackingSDK is a framework that provides event tracking capabilities for iOS applications.
                       DESC
  
  s.homepage         = 'https://github.com/shujushuo/tracking-ios-sdk'
  s.license          = { :type => "Apache License, Version 2.0", :file => "../LICENSE" }
  s.author           = { "jiangzhenxing" => "3728973@qq.com" }
  s.source           = { :git => 'https://github.com/shujushuo/tracking-ios-sdk.git', :tag => 'v0.2.1' }
  s.platform         = :ios, '10.0'
  
  # 确保路径正确
  s.source_files     = 'TrackingSDK/**/*.{h,m}'
  s.public_header_files = 'TrackingSDK/**/*.h'
  
  # 依赖项
  s.requires_arc     = true
  s.dependency 'FMDB', '~> 2.7'
  
  # 系统框架
  s.frameworks = 'AdSupport'
  
end