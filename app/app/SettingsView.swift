import SwiftUI
import AdSupport
import AppTrackingTransparency
import UIKit
import TrackingSDK

struct SettingsView: View {
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    // 用 @State 保存设备信息
    @State private var features: [(title: String, text: String)] = []
    // 获取设备信息的方法
    private func getDeviceInfo() -> [(title: String, text: String)] {
        return [
            ("设备品牌", "apple"), // 设备品牌，例如 iPhone 12
            ("设备型号", TrackingID.sharedInstance().getModel()), // 获取设备型号
            ("系统版本", TrackingID.sharedInstance().getSystemVersion()), // 系统版本，例如 iOS 16.4
            ("IDFA", TrackingID.sharedInstance().getIDFA()), // 获取IDFA
            ("CAID", TrackingID.sharedInstance().getTrackingID()), // 获取CAID
            ("IDFV", TrackingID.sharedInstance().getIDFV()), // 获取IDFV
            ("Install ID", TrackingID.sharedInstance().getInstallID()), // 用UUID生成的Install ID
            ("包名", TrackingID.sharedInstance().getPkgName()), // 系统版本，例如
            ("包版本", TrackingID.sharedInstance().getPkgVersion()), // 系统版本，例如 1.0.0
        ]
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
                            // HStack：标题和按钮在同一行
                            HStack {
                                // 每组的标题
                                Text(feature.title)
                                    .font(.headline)
                                    .padding(.bottom, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)  // 左对齐
                                
                                
                                // 复制按钮
                                Button(action: {
                                    // 按钮点击事件，复制到剪贴板
                                    UIPasteboard.general.string = feature.text
                                    
                                    // 检查剪贴板内容
                                    if UIPasteboard.general.string == feature.text {
                                        alertMessage = "复制成功！"
                                    } else {
                                        alertMessage = "复制失败！"
                                    }
                                    showAlert = true
                                    // 延迟关闭提示
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showAlert = false
                                    }
                                }) {
                                    Text("Copy")
                                        .padding(8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(.leading, 3)
                                .frame(maxWidth: .infinity, alignment: .trailing)  // 右对齐
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text(alertMessage), dismissButton: .default(Text("OK")))
                                }
                            }
                            // 文本框（不可编辑）
                            TextField("", text: .constant(feature.text))
                                .disabled(true) // 禁用编辑
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
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


