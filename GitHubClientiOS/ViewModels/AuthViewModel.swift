//
//  AuthViewModel.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI
import LocalAuthentication

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: ErrorWrap?
    @Published var isBiometricAvailable: Bool = false
    @Published var isBiometricEnabled: Bool = false
    @Published var biometricType: BiometricType = .none
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = SecureAuthService.shared) {
        self.authService = authService
        checkLoginStatus()
        setupBiometricAuthentication()
    }
    
    // 检查登录状态
    func checkLoginStatus() {
        isLoggedIn = authService.isLoggedIn
    }
    
    // 初始化生物识别状态
    func setupBiometricAuthentication() {
        isBiometricAvailable = authService.isBiometricAuthenticationAvailable()
        biometricType = authService.biometricType()
        
        // 检查是否已启用生物识别登录
        do {
            isBiometricEnabled = try authService.isBiometricLoginEnabled()
        } catch {
            print("检查生物识别状态失败: \(error.localizedDescription)")
            isBiometricEnabled = false
        }
    }
    
    // 启动GitHub授权流程
    func startAuthorization() {
        guard let authURL = authService.startGitHubAuthorization() else {
            errorMessage = ErrorWrap(localizedDescription: "无法启动授权流程")
            return
        }
        
        UIApplication.shared.open(authURL)
    }
    
    // 切换生物识别登录状态
    func toggleBiometricLogin(enabled: Bool) {
        do {
            try authService.toggleBiometricLogin(enabled: enabled)
            isBiometricEnabled = enabled
        } catch {
            errorMessage = ErrorWrap(localizedDescription: error.localizedDescription)
        }
    }
    
    // 生物识别验证
    func authenticateWithBiometrics() {
        Task {
            do {
                let reason = biometricType == .faceID ?
                    "使用Face ID验证以登录GitHub" :
                    "使用Touch ID验证以登录GitHub"
                
                let success = try await authService.startBiometricsAuthorization(reason: reason)
                if success {
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                        NotificationCenter.default.post(name: .loginSuccess, object: nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = ErrorWrap(localizedDescription: error.localizedDescription)
                }
            }
        }
    }
    
    // 登出
    func logout() {
        do {
            try authService.logout()
            isLoggedIn = false
            NotificationCenter.default.post(name: .logoutSuccess, object: nil)
        } catch {
            errorMessage = ErrorWrap(localizedDescription: error.localizedDescription)
        }
    }
}
