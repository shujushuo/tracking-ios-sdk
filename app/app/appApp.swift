import SwiftUI
import SjsTrackingSDK
import AdSupport
import AppTrackingTransparency

@main
struct appApp: App {
    @Environment(\.colorScheme) var colorScheme // 使用环境变量来控制色彩方案
    
    init() {
        // 初始时强制设置白天模式
        if #available(iOS 15.0, *) {
            // 获取当前窗口场景并设置为浅色模式
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = .light
                }
            }
        } else {
            // iOS 15 以下的版本直接使用 windows
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
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
                }.preferredColorScheme(.light)
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
        TrackingSDK.sharedInstance().preInitialize("200_1001", serverURL: "http://127.0.0.1:8090/")
        
    }
}
