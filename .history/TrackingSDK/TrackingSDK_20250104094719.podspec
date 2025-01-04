Pod::Spec.new do |spec|
  spec.name         = "TrackingSDK"
  spec.version      = "0.2.1"
  spec.summary      = "A SDK for AD Tracking"
  spec.description  = "A SDK for AD Tracking"
  spec.homepage     = "https://github.com/shujushuo/tracking-ios-sdk"
  spec.license      = "Apache License, Version 2.0"
  spec.author             = { "jiangzhenxing" => "jiangzhx@gmail.com" }
  spec.source       = { :git => "https://github.com/shujushuo/tracking-ios-sdk.git", :tag => "#{spec.version}" }
  s.source_files     = 'TrackingSDK/Sources/**/*.{swift,h,m}'
  s.resources        = 'TrackingSDK/Resources/**/*.{xib,storyboard,png,jpg}'
end
