import SwiftUI
import SjsTrackingSDK

struct HomeView: View {
    @State private var serverUrl: String = "http://127.0.0.1:8090/"
    @State private var appid: String = "200_1001"
    @State private var channelid: String = "DEFAULT"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 页面标题
                HStack {
                    Spacer()
                    Text("模拟事件上报")
                        .font(.largeTitle)  // 设置字体大小
                        .fontWeight(.bold)  // 设置字体加粗
                    Spacer()
                }
                .padding(.top) // 适当的顶部间距，避免和屏幕顶端紧贴
                
                // 服务器地址输入框
                VStack(alignment: .leading) {
                    Text("服务器地址")
                        .font(.headline)
                    TextField("", text: $serverUrl)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                }
                
                // 第二个和第三个输入框并排
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("APP ID")
                            .font(.headline)
                        TextField("", text: $appid)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Channel ID")
                            .font(.headline)
                        TextField("", text: $channelid)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
                
                // 保存配置并初始化SDK按钮
                Button(action: saveAndInitializeSDK) {
                    Text("保存配置并初始化SDK")
                        .frame(maxWidth: .infinity,minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                // 其他按钮
                Button(action: {
                    TrackingSDK.sharedInstance().trackInstallEvent()
                }) {
                    Text("激活")
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Button(action: {
                    TrackingSDK.sharedInstance().trackStartupEvent()
                }) {
                    Text("启动")
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Button(action: {
                    TrackingSDK.sharedInstance().trackRegisterEvent("example_xwho")
                }) {
                    Text("注册")
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Button(action: {
                    TrackingSDK.sharedInstance().trackLoginEvent("example_xwho")
                }) {
                    Text("登录")
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Button(action: {
                    TrackingSDK.sharedInstance().trackPaymentEvent("example_xwho",
                                                                   transactionID: "exampe_transactionid",
                                                                   paymentType: "wechat",
                                                                   currencyType: CurrencyType.CNY,
                                                                   currencyAmount: 0.99)
                }) {
                    Text("付费")
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }                
                Spacer()
            }
            .padding()
            .onAppear(perform: loadSavedConfig) // 加载保存的配置
        }
    }
    
    // 保存配置并初始化SDK
    private func saveAndInitializeSDK() {
            UserDefaults.standard.set(serverUrl, forKey: "serverURL")
            UserDefaults.standard.set(appid, forKey: "appid")
            UserDefaults.standard.set(channelid, forKey: "channelID")
            TrackingSDK.sharedInstance().setLoggingEnabled(true);
            TrackingSDK.sharedInstance().initialize()
            print("保存配置并初始化SDK")
    }
    
    // 加载保存的配置
    private func loadSavedConfig() {
        if let savedServerURL = UserDefaults.standard.string(forKey: "serverURL") {
            serverUrl = savedServerURL
        }
        if let savedAppID = UserDefaults.standard.string(forKey: "appid") {
            appid = savedAppID
        }
        if let savedChannelID = UserDefaults.standard.string(forKey: "channelID") {
            channelid = savedChannelID
        }
    }
    
    // 创建通用的按钮
    private func actionButton(title: String) -> some View {
        Button(action: {
            print("\(title)按钮被点击")
        }) {
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 15)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(5)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
