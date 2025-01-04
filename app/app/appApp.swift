import SwiftUI
import TrackingSDK

@available(iOS 14.0, *)
@main
struct appApp: App {
    init() {
        // 初始化 SDK
        TrackingSDK.sharedInstance().initialize(withAppID: "https://127.0.0.1/up", serverURL: "APPID")
//        Tracking.shared.initialize(serverURL: "https://your-server-url.com/upload", appid: "YOUR_APP_ID")
//        // 可选：记录一个安装事件
//        let additionalContext: [String: Any] = [
//            "channelid": "example_channelid",
//            "user_level": 5,
//            "is_premium": true,
//            "score": 98.6
//        ]
//        Tracking.shared.logEvent(xwhat: "install", xwho: "someoneelse", xcontext: additionalContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
