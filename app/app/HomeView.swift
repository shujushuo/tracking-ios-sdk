import SwiftUI

struct HomeView: View {
    @State private var serverUrl: String = ""
    @State private var appid: String = ""
    @State private var channelid: String = ""
    
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
                VStack(alignment: .leading) {
                    Text("服务器地址")
                        .font(.headline)
                    TextField("http://10.1.64.179:8090/", text: $serverUrl)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                }
                
                // 第二个和第三个输入框并排
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("APP ID")
                            .font(.headline)
                        TextField("APPID", text: $appid)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Channel ID")
                            .font(.headline)
                        TextField("DEFAULT", text: $channelid)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
                
                Button(action: {
                    print("保存配置并初始化SDK")
                }) {
                    Text("保存配置并初始化SDK")
                        .frame(maxWidth: .infinity,minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    print("激活")
                }) {
                    Text("激活")
                        .frame(maxWidth: .infinity,minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    print("启动")
                }) {
                    Text("启动")
                        .frame(maxWidth: .infinity,minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    print("登录")
                }) {
                    Text("登录")
                        .frame(maxWidth: .infinity,minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    print("注册")
                }) {
                    Text("注册")
                        .frame(maxWidth: .infinity,minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    print("付费")
                }) {
                    Text("付费")
                        .frame(maxWidth: .infinity,minHeight: 15)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
