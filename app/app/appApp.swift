import SwiftUI
import SjsTrackingSDK
import AdSupport
import AppTrackingTransparency

@main
struct appApp: App {
    init() {
        // 应用启动时无需立即请求权限
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 在应用首次显示时延迟请求权限
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // 延迟请求授权
                        requestTrackingPermission()
                    }
                }
        }
    }
    
    func requestTrackingPermission() {
        // 检查跟踪授权状态
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                print("Tracking authorization status: \(status)")
                switch status {
                case .authorized:
                    print("用户授权了应用跟踪")
                    // 可以访问广告标识符 (IDFA)
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("IDFA: \(idfa)")
                case .denied:
                    print("用户拒绝了应用跟踪")
                case .restricted:
                    print("应用跟踪权限受限")
                case .notDetermined:
                    print("用户尚未决定是否允许应用跟踪")
                @unknown default:
                    print("未知的跟踪授权状态")
                }
            }
        } else {
            print("iOS 14 或更高版本才能使用 AppTrackingTransparency")
        }
        
        TrackingSDK.sharedInstance().setLoggingEnabled(true);
        TrackingSDK.sharedInstance().preInitialize("APPID", serverURL: "http://192.168.1.102:8090")

    }
}
