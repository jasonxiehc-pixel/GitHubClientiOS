//
//  AuthService.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import Alamofire

/// 基于Keychain的安全认证服务实现
final class SecureAuthService: AuthServiceProtocol {
    /// 单例实例
    static let shared: AuthServiceProtocol = SecureAuthService()
    
    /// 钥匙串服务
    private let keychainService: KeychainServiceProtocol
    
    /// 网络服务
    private let networkService: NetworkServiceProtocol
    
    /// 生物识别服务
    private let biometricService: BiometricAuthServiceProtocol
    
    static let cliEnvPlist: [String: String] = {
        guard let filePath = Bundle.main.path(forResource: "ClientEnv", ofType: "plist") else { return [:] }
        guard let dict = NSDictionary(contentsOfFile: filePath) else { return [:] }
        return dict as! [String : String]
    }()
    
    /// OAuth配置 - 实际项目中应使用自己的客户端ID和密钥
    struct OAuthConfig {
        static let clientID = cliEnvPlist["CLI_ID"] // GitHub客户端ID
        static let clientSecret = cliEnvPlist["CLI_SEC"] // GitHub客户端密钥
        static let redirectURI = cliEnvPlist["CLI_REDIR_URL"] // 回调URL
        static let scope = "read:user,public_repo" // 请求的权限范围
        static let state = UUID().uuidString // 防止CSRF攻击的随机字符串
    }
    
    /// 存储的状态值，用于验证回调
    private var storedState: String?
    
    /// 钥匙串存储键
    private enum KeychainKeys {
        static let accessToken = "github_access_token"
        static let biometricEnabled = "biometric_login_enabled"
        static let refreshToken = "github_refresh_token"
    }
    
    /// 初始化
    init(
        keychainService: KeychainServiceProtocol = KeychainService.shared,
        networkService: NetworkServiceProtocol = NetworkService.shared,
        biometricService: BiometricAuthServiceProtocol = BiometricAuthService.shared
    ) {
        self.keychainService = keychainService
        self.networkService = networkService
        self.biometricService = biometricService
    }
    
    /// AuthServiceProtocol Impl
    
    /// 检查用户是否已登录
    var isLoggedIn: Bool {
        do {
            return try keychainService.getString(forKey: KeychainKeys.accessToken) != nil
        } catch {
            return false
        }
    }
    
    /// 获取当前存储的访问令牌
    func getStoredToken() throws -> String {
        guard let token = try keychainService.getString(forKey: KeychainKeys.accessToken) else {
            throw AuthError.notAuthenticated
        }
        return token
    }
    
    /// 启动GitHub授权流程
    func startGitHubAuthorization() -> URL? {
        // 生成并存储状态值
        storedState = OAuthConfig.state
        
        // 构建授权URL
        var components = URLComponents(string: "https://github.com/login/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: OAuthConfig.clientID),
            URLQueryItem(name: "redirect_uri", value: OAuthConfig.redirectURI),
            URLQueryItem(name: "scope", value: OAuthConfig.scope),
            URLQueryItem(name: "state", value: storedState)
        ]
        
        return components?.url
    }
    
    /// 处理授权回调URL
    func handleGitHubAuthorizationCallback(url: URL) async throws -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
              let state = components.queryItems?.first(where: { $0.name == "state" })?.value else {
            throw AuthError.invalidCallbackURL
        }
        
        // 验证状态值，防止CSRF攻击
        guard state == storedState else {
            throw AuthError.invalidState
        }
        
        // 交换访问令牌
        let (accessToken, refreshToken) = try await exchangeToken(code: code)
        
        // 存储访问令牌和刷新令牌
        try keychainService.setString(accessToken, forKey: KeychainKeys.accessToken)
        if let refreshToken = refreshToken {
            try keychainService.setString(refreshToken, forKey: KeychainKeys.refreshToken)
        }
        
        return true
    }
    
    /// 使用授权码交换访问令牌
    private func exchangeToken(code: String) async throws -> (accessToken: String, refreshToken: String?) {
        let url = "https://github.com/login/oauth/access_token"
        
        let params: Parameters = [
            "client_id": OAuthConfig.clientID,
            "client_secret": OAuthConfig.clientSecret,
            "code": code,
            "redirect_uri": OAuthConfig.redirectURI
        ]
        
        var headers = HTTPHeaders()
        headers.add(name: "Accept", value: "application/json")
        
        // 发送请求交换令牌
        let response: TokenResponse = try await networkService.request(
            url: url,
            method: .post,
            params: params,
            headers: headers,
            decoder: JSONDecoder()
        )
        
        guard let accessToken = response.accessToken else {
            if let error = response.error {
                throw AuthError.oauthError(message: error)
            } else {
                throw AuthError.tokenExchangeFailed
            }
        }
        
        return (accessToken, response.refreshToken)
    }
    
    /// 登出并清除所有认证信息
    func logout() throws {
        try keychainService.removeValue(forKey: KeychainKeys.accessToken)
        try keychainService.removeValue(forKey: KeychainKeys.refreshToken)
        storedState = nil
        
        // 发送登出通知
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }
    
    /// 获取当前登录用户信息
    func getCurrentUser() async throws -> User {
        let token = try getStoredToken()
        let url = "https://api.github.com/user"
        
        var headers = HTTPHeaders()
        headers.add(name: "Authorization", value: "token \(token)")
        headers.add(name: "Accept", value: "application/json")
        //headers.add(name: "Accept", value: "application/vnd.github.v3+json")
        
        return try await networkService.request(
            url: url,
            method: .get,
            params: nil,
            headers: headers,
            decoder: createDecoder()
        )
    }
    
    // MARK: - 辅助方法
    
    /// 创建默认的JSON解码器
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    // MARK: - 生物识别相关实现
    
    /// 进行生物识别验证
    func startBiometricsAuthorization(reason: String) async throws -> Bool {
        // 检查是否已启用生物识别登录
        guard try isBiometricLoginEnabled() else {
            throw AuthError.biometricLoginNotEnabled
        }
        
        do {
            return try await biometricService.doBiometricAuth(reason: reason)
        }
        catch let error as BiometricAuthError {
            throw AuthError.biometricError(error)
        }
        catch {
            throw AuthError.unknownError
        }
    }
    
    /// 检查设备是否支持生物识别
    func isBiometricAuthenticationAvailable() -> Bool {
        return biometricService.isBiometricAvailable()
    }
    
    /// 获取生物识别类型
    func biometricType() -> BiometricType {
        return biometricService.getBiometricType()
    }
    
    /// 检查是否已启用生物识别登录
    func isBiometricLoginEnabled() throws -> Bool {
        return try keychainService.getBool(forKey: KeychainKeys.biometricEnabled) ?? false
    }
    
    /// 切换生物识别登录状态
    func toggleBiometricLogin(enabled: Bool) throws {
        try keychainService.setBool(enabled, forKey: KeychainKeys.biometricEnabled)
    }
}

/// 认证相关错误
enum AuthError: Error, LocalizedError, Equatable {
    case notAuthenticated
    case invalidCallbackURL
    case invalidState
    case tokenExchangeFailed
    case oauthError(message: String)
    case userInfoFailed
    // 生物识别相关错误
    case biometricLoginNotEnabled
    case biometricError(BiometricAuthError)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return NSLocalizedString("用户未登录", comment: "")
        case .invalidCallbackURL:
            return NSLocalizedString("无效的回调URL", comment: "")
        case .invalidState:
            return NSLocalizedString("状态验证失败，可能存在安全风险", comment: "")
        case .tokenExchangeFailed:
            return NSLocalizedString("令牌交换失败", comment: "")
        case .oauthError(let message):
            return String(format: NSLocalizedString("授权错误: %@", comment: ""), message)
        case .userInfoFailed:
            return NSLocalizedString("获取用户信息失败", comment: "")
        case .biometricLoginNotEnabled:
            return NSLocalizedString("未启用生物识别登录", comment: "")
        case .biometricError(let error):
            return error.localizedDescription
        case .unknownError:
            return NSLocalizedString("未知认证错误", comment: "")
        }
    }
}

/// 令牌响应模型
private struct TokenResponse: Decodable {
    let accessToken: String?
    let tokenType: String?
    let scope: String?
    let refreshToken: String?
    let error: String?
    let errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case refreshToken = "refresh_token"
        case error
        case errorDescription = "error_description"
    }
}

// 通知扩展
extension Notification.Name {
    /// 用户登出通知
    static let userLoggedOut = Notification.Name("UserLoggedOut")
}

