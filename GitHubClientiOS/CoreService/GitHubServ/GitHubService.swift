//
//  GitHubService.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import Alamofire

/// GitHub API服务实现
final class GitHubService: GitHubServiceProtocol {
    /// 单例实例
    static let shared: GitHubServiceProtocol = GitHubService()
    
    static let baseURL = "https://api.github.com"
    static let defaultPerPage = 20
    
    // MARK: - 依赖
    private let networkService: NetworkServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - 初始化
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         authService: AuthServiceProtocol = SecureAuthService.shared) {
        self.networkService = networkService
        self.authService = authService
    }
    
    // MARK: - 私有方法
    /// 创建请求头（包含认证信息）
    private func createHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders.default
        //headers.add(name: "Accept", value: "application/vnd.github.v3+json")
        headers.add(name: "Accept", value: "application/json")
        headers.add(name: "User-Agent", value: "HWClientiOS")
        
        // 如果用户已登录，添加认证信息
        if authService.isLoggedIn, let token = try? authService.getStoredToken() {
            headers.add(name: "Authorization", value: "token \(token)")
        }
        
        return headers
    }
    
    /// 创建默认的JSON解码器
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    /// 处理网络请求错误，转换为GitHubError
    private func handleError(_ error: Error) throws -> Never {
        if let networkError = error as? NetworkError {
            throw GitHubError.networkError(networkError)
        } else {
            throw GitHubError.unknownError
        }
    }
    
    // 构建完整 URL
    private func buildURL(base: String, with params: [String: String]) -> String {
        guard var components = URLComponents(string: base) else { return "" }
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.string ?? ""
    }
    
    // MARK: - 接口请求
    
    /// 获取综合热门仓库
    func getTrendingRepositories(days: Int = 30, page: Int = 1, perPage: Int = GitHubService.defaultPerPage) async throws -> RepositoryListResponse {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let dateStr = dateFormatter.string(from: thirtyDaysAgo)
        
        let base = "\(GitHubService.baseURL)/search/repositories"
        
        let params = [
            "q": "stars:>5000+created:>\(dateStr)",
            "sort": "stars",
            "order": "desc",
            "page": "\(page)",
            "per_page": "\(perPage)"
        ]
        let url = buildURL(base: base, with: params)
        
        do {
            return try await networkService.request(
                url: url,
                method: .get,
                params: nil,
                headers: createHeaders(),
                decoder: createDecoder()
            )
        } catch {
            try handleError(error)
        }
    }
    
    /// 搜索仓库
    func searchRepositories(query: String, page: Int = 1, perPage: Int = GitHubService.defaultPerPage) async throws -> RepositoryListResponse {
        
        guard !query.isEmpty else {
            throw GitHubError.invalidQuery
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = "\(GitHubService.baseURL)/search/repositories?q=\(encodedQuery)&page=\(page)&per_page=\(perPage)"
        
        do {
            return try await networkService.request(
                url: url,
                method: .get,
                params: nil,
                headers: createHeaders(),
                decoder: createDecoder()
            )
        } catch {
            try handleError(error)
        }
    }
    
    /// 获取用户仓库
    func getUserRepositories(username: String, page: Int = 1, perPage: Int = GitHubService.defaultPerPage) async throws -> [Repository] {
        
        guard !username.isEmpty else {
            throw GitHubError.invalidUsername
        }
        
        let url = "\(GitHubService.baseURL)/users/\(username)/repos?page=\(page)&per_page=\(perPage)&sort=pushed"
        
        do {
            return try await networkService.request(
                url: url,
                method: .get,
                params: nil,
                headers: createHeaders(),
                decoder: createDecoder()
            )
        } catch {
            try handleError(error)
        }
    }
    
    /// 获取用户资料
    func getUserProfile(username: String) async throws -> User {
        guard !username.isEmpty else {
            throw GitHubError.invalidUsername
        }
        
        let url = "\(GitHubService.baseURL)/users/\(username)"
        
        do {
            return try await networkService.request(
                url: url,
                method: .get,
                params: nil,
                headers: createHeaders(),
                decoder: createDecoder()
            )
        } catch {
            try handleError(error)
        }
    }
    
    /// 获取当前登录用户的仓库
    func getCurrentUserRepositories(page: Int = 1, perPage: Int = GitHubService.defaultPerPage) async throws -> [Repository] {
        // 检查用户是否已登录
        guard authService.isLoggedIn else {
            throw GitHubError.notAuthenticated
        }
        
        let url = "\(GitHubService.baseURL)/user/repos?page=\(page)&per_page=\(perPage)&sort=pushed"
        
        do {
            return try await networkService.request(
                url: url,
                method: .get,
                params: nil,
                headers: createHeaders(),
                decoder: createDecoder()
            )
        } catch {
            try handleError(error)
        }
    }
    
    /// 获取当前登录用户资料
    func getCurrentUserProfile() async throws -> User {
        // 检查用户是否已登录
        guard authService.isLoggedIn else {
            throw GitHubError.notAuthenticated
        }
        
        let url = "\(GitHubService.baseURL)/user"
        
        do {
            return try await networkService.request(
                url: url,
                method: .get,
                params: nil,
                headers: createHeaders(),
                decoder: createDecoder()
            )
        } catch {
            try handleError(error)
        }
    }
}

/// GitHub服务错误类型
enum GitHubError: Error, LocalizedError {
    case invalidQuery
    case invalidUsername
    case notAuthenticated
    case networkError(NetworkError)
    case authError(AuthError)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return NSLocalizedString("无效的搜索关键词", comment: "")
        case .invalidUsername:
            return NSLocalizedString("无效的用户名", comment: "")
        case .notAuthenticated:
            return NSLocalizedString("请先登录", comment: "")
        case .networkError(let error):
            return error.localizedDescription
        case .authError(let error):
            return error.localizedDescription
        case .unknownError:
            return NSLocalizedString("未知错误", comment: "")
        }
    }
}
