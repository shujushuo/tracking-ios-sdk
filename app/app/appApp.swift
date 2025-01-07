import SwiftUI
import TrackingSDK
import AdSupport
import AppTrackingTransparency

@available(iOS 14.0, *)
@main
struct appApp: App {
    init() {
        requestIDFAAuthorization()

        // 初始化 SDK
        // 确保在请求IDFA授权之后初始化SDK
        TrackingSDK.sharedInstance().initialize(withAppID: "https://127.0.0.1/up", serverURL: "APPID")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func requestIDFAAuthorization() {
        // 直接调用ATTrackingManager.requestTrackingAuthorization
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("IDFA授权成功")
                // 可以访问IDFA
                let idfa = ASIdentifierManager.shared().advertisingIdentifier
                print("IDFA: \(idfa)")
                
            case .denied, .restricted, .notDetermined:
                print("IDFA授权失败或未决定")
                // 无法获取IDFA，可能需要跳转到设置页面引导用户修改
            @unknown default:
                print("未知的状态")
            }
        }
    }
}
