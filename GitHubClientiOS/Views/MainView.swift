//
//  MainView.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    // 监听登录状态变化
    @State private var isLoggedIn = false
    
    var body: some View {
        TabView {
            // 热门仓库标签页 - 未登录可访问
            TrendingRepositoryView()
                .tabItem {
                    Image("hot_tab")
                    Text("热门")
                }
            
            // 搜索标签页 - 未登录可访问
            SearchRepositoryView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("搜索")
                }
            
            // 个人资料标签页 - 根据登录状态显示不同内容
            Group {
                if isLoggedIn {
                    ProfileView()
                } else {
                    LoginPromptView()
                }
            }
            .tabItem {
                Image(systemName: "person")
                Text("我的")
            }
        }
        .onAppear {
            Task {
                await checkLoginStatus()
            }
            setupNotificationObservers()
        }
    }
    
    // 检查登录状态
    private func checkLoginStatus() async {
        isLoggedIn = authViewModel.isLoggedIn
        if isLoggedIn {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            profileViewModel.loadCurrentUserProfile()
        }
    }
    
    // 设置通知观察者
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .loginSuccess,
            object: nil,
            queue: .main
        ) { _ in
            self.isLoggedIn = true
            self.profileViewModel.loadCurrentUserProfile()
        }
        
        NotificationCenter.default.addObserver(
            forName: .logoutSuccess,
            object: nil,
            queue: .main
        ) { _ in
            self.isLoggedIn = false
        }
    }
}

// 未登录状态下的个人标签页提示
struct LoginPromptView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("请登录以查看个人资料")
                .font(.title)
                .foregroundColor(.secondary)
            
            Button(action: {
                authViewModel.startAuthorization()
            }) {
                Text("使用GitHub账号登录")
                    .frame(minWidth: 0, maxWidth: 200)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("LoginPromptGitHubLogin")
            
            // 生物识别登录选项
            if authViewModel.isBiometricAvailable && authViewModel.isBiometricEnabled {
                Button(action: {
                    authViewModel.authenticateWithBiometrics()
                }) {
                    HStack {
                        Image(systemName: authViewModel.biometricType == .faceID ? "faceid" : "touchid")
                        Text(authViewModel.biometricType == .faceID ? "使用Face ID登录" : "使用Touch ID登录")
                    }
                    .frame(minWidth: 0, maxWidth: 200)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel())
            .environmentObject(RepositoryListViewModel())
            .environmentObject(ProfileViewModel())
    }
}

