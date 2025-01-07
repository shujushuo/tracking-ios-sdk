import SwiftUI
import AdSupport
import AppTrackingTransparency
import UIKit

struct SettingsView: View {
    
    // 用 @State 保存设备信息
    @State private var features: [(title: String, text: String)] = []
    // 获取设备信息的方法
    private func getDeviceInfo() -> [(title: String, text: String)] {

        let device = UIDevice.current
        let installID = UUID().uuidString // 用UUID生成一个Install ID
        
        // 返回包含所有设备信息的数组
        return [
            ("设备品牌", device.name), // 设备品牌，例如 iPhone 12
            ("设备型号", getDeviceModel()), // 获取设备型号
            ("系统版本", device.systemVersion), // 系统版本，例如 iOS 16.4
            ("Install ID", installID), // 用UUID生成的Install ID
            ("IDFA", getIDFA()), // 获取IDFA
            ("CAID", "自定义的CAID"), // 这里是占位符
            ("IDFV", getIDFV()) // 获取IDFV
        ]
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let model = withUnsafePointer(to: &systemInfo.machine) { (pointer) -> String in
            let data = Data(bytes: pointer, count: Int(_SYS_NAMELEN))
            if let model = String(data: data, encoding: .utf8) {
                return model.trimmingCharacters(in: .controlCharacters)
            }
            return "Unknown"
        }
        
        // 通过硬件标识符映射表转换硬件标识符为设备名称
        return model
    }
    
    // 获取IDFA的方法
    private func getIDFA() -> String {
        var idfaString = "IDFA 未授权"
        
        // 检查用户是否已授权
        if ATTrackingManager.trackingAuthorizationStatus == .authorized {
            // 如果授权，获取IDFA
            idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            // 如果未授权，提示用户
            idfaString = "IDFA 未启用"
        }
        
        return idfaString
    }
    
    // 获取IDFV的方法
    private func getIDFV() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "IDFV 未获取"
    }
    
    // 在视图初始化时加载设备信息
    init() {
        // 初始化时计算设备信息
        _features = State(initialValue: getDeviceInfo())
    }

    var body: some View {
        ScrollView { // 用ScrollView包装整个内容，防止溢出
            VStack {
                // 标题部分
                HStack {
                    Spacer()
                    Text("设备ID信息")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
                .padding(.top) // 适当的顶部间距，避免和屏幕顶端紧贴

                // 使用ForEach来创建每一组
                ForEach(features, id: \.title) { feature in
                    Group {
                        VStack(alignment: .leading, spacing: 12) {
                            // 每组的标题
                            Text(feature.title)
                                .font(.headline)
                                .padding(.bottom, 4)

                            // HStack：文本框和按钮在同一行
                            HStack {
                                // 文本框（不可编辑）
                                TextField("", text: .constant(feature.text))
                                    .disabled(true) // 禁用编辑
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)

                                // 复制按钮
                                Button(action: {
                                    // 按钮点击事件，复制到剪贴板
                                    UIPasteboard.general.string = feature.text
                                }) {
                                    Text("Copy")
                                        .padding(8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(.leading, 3) // 给按钮与文本框之间添加一点水平间距
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.vertical, 8) // 每组之间的垂直间距
                    }
                }
            }
            .padding() // 外部内容的 padding
        }
    }
}


