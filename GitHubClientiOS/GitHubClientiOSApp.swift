//
//  GitHubClientiOSApp.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import SwiftUI

@main
struct GitHubClientiOSApp: App {
    // 初始化核心服务
    private let authService: AuthServiceProtocol = SecureAuthService.shared
    private let githubService: GitHubServiceProtocol = GitHubService.shared
    
    // 处理URL回调
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            // 根视图根据登录状态决定，但始终可以访问首页
            MainView()
                .environmentObject(AuthViewModel(authService: authService))
                .environmentObject(RepositoryListViewModel(githubService: githubService))
                .environmentObject(ProfileViewModel(githubService: githubService, authService: authService))
                .onOpenURL(perform: handleURL)
        }
    }
    
    // 处理GitHub授权登录认证回调URL
    private func handleURL(_ url: URL) {
        Task {
            let success = try await authService.handleGitHubAuthorizationCallback(url: url)
            if success {
                NotificationCenter.default.post(name: .loginSuccess, object: nil)
            }
        }
    }
}

// 应用代理，处理后台事件
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 初始化设置
        return true
    }
}

// 通知扩展
extension Notification.Name {
    static let loginSuccess = Notification.Name("LoginSuccess")
    static let logoutSuccess = Notification.Name("LogoutSuccess")
}

