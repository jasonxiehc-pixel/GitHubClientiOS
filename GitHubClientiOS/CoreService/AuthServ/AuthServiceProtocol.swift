//
//  AuthServiceProtocol.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation

enum AuthResult {
    case succeed
    case failure(String)
    case canceled
}

/// 用户认证信息模型
struct AuthCredentials {
    let username: String
    let token: String?
    let password: String?
}

/// 认证服务协议
protocol AuthServiceProtocol {
    /// 当前是否有已登录用户
    var isLoggedIn: Bool { get }
    
    /// 获取当前存储的访问令牌
    func getStoredToken() throws -> String
    
    /// 启动GitHub授权流程
    /// - Returns: 授权URL
    func startGitHubAuthorization() -> URL?
    
    /// 处理授权回调URL
    /// - Parameter url: 回调URL
    /// - Returns: 是否处理成功
    func handleGitHubAuthorizationCallback(url: URL) async throws -> Bool
    
    /// 获取当前登录用户信息
    func getCurrentUser() async throws -> User
    
    /// 登出并清除所有认证信息
    func logout() throws
    
    
    /// 使用生物识别登录相关方法
    /// - Returns: 登录成功的用户凭证
    func startBiometricsAuthorization(reason: String) async throws -> Bool
    
    /// 检查设备是否支持生物识别
    func isBiometricAuthenticationAvailable() -> Bool
    
    /// 获取生物识别类型
    func biometricType() -> BiometricType
    
    /// 检查是否已启用生物识别登录
    func isBiometricLoginEnabled() throws -> Bool
    
    /// 切换生物识别登录状态
    func toggleBiometricLogin(enabled: Bool) throws
}


