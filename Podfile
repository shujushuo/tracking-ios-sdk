platform :ios, '12.0'

# 指定 Workspace 名称
workspace 'appDemo.xcworkspace'

project 'app/app.xcodeproj'

# 集成 App 的依赖
target 'app' do
  use_frameworks!
  use_modular_headers!
  
  # 集成本地的 TrackingSDK
  pod 'SjsTrackingSDK', :path => './SjsTrackingSDK'

  post_install do |installer|
  	installer.pods_project.targets.each do |target|
  		target.build_configurations.each do |config|
        if target.name == 'SjsTrackingSDK'
          config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "10.0"
        else
          # 其他 Pods 或 App Target 可以支持更高版本
          config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
        end  		
      end
  	end
  end
end
