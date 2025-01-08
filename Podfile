platform :ios, '15.0'

# 指定 Workspace 名称
workspace 'appDemo.xcworkspace'

project 'app/app.xcodeproj'

# 集成 App 的依赖
target 'app' do
  use_frameworks!
  # Pods for app
  pod 'Reachability', '~> 3.2.0'
  pod 'FMDB', '~> 2.7'
  
  
  # 集成本地的 TrackingSDK
  pod 'TrackingSDK', :path => './TrackingSDK'

  post_install do |installer|
  	installer.pods_project.targets.each do |target|
  		target.build_configurations.each do |config|
  			config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "10.0"
  		end 
  	end
  end
  
end
