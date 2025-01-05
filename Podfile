platform :ios, '15.0'

use_frameworks! 

# 指定 Workspace 名称
workspace 'tracking-ios-sdk.xcworkspace'

project 'app/app.xcodeproj'

# 集成 App 的依赖
target 'app' do
  # Pods for app
  
  # 集成本地的 TrackingSDK
  pod 'TrackingSDK', :path => './TrackingSDK'
end
