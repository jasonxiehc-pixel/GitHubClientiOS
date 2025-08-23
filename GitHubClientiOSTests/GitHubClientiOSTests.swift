//
//  GitHubClientiOSTests.swift
//  GitHubClientiOSTests
//
//  Created by xiehanchao on 2025/8/22.
//

import XCTest
import Combine
import Alamofire
import SwiftyJSON
@testable import GitHubClientiOS

class GitHubClientiOSTests: XCTestCase {
    // 测试依赖
    private var githubService: GitHubServiceProtocol!
    private var mockNetworkService: MockNetworkService!
    private var authService: AuthServiceProtocol!
    private var cancellables: Set<AnyCancellable>!
    
    // 每个测试方法执行前调用
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        githubService = GitHubService(networkService: mockNetworkService)
        authService = SecureAuthService()
        cancellables = []
    }
    
    // 每个测试方法执行后调用
    override func tearDown() {
        githubService = nil
        mockNetworkService = nil
        authService = nil
        cancellables = nil
        super.tearDown()
    }
    
    /// 测试热门仓库获取功能
    func testGetTrendingRepositories() async throws {
        // 准备模拟数据
        var mockRespJSON: JSON {
            return JSON([
                "total_count": 120,
                "incomplete_results": false,
                "items": [
                    [
                        "id": 1296269,
                        "name": "react",
                        "full_name": "facebook/react",
                        "owner": [
                            "login": "facebook",
                            "avatar_url": "https://avatars.githubusercontent.com/u/69631?v=4"
                        ],
                        "stargazers_count": 200000,
                        "language": "JavaScript",
                        "topics": ["react", "ui", "javascript"]
                    ],
                    [
                        "id": 21262443,
                        "name": "swift",
                        "full_name": "apple/swift",
                        "owner": [
                            "login": "apple",
                            "avatar_url": "https://avatars.githubusercontent.com/u/10639145?v=4"
                        ],
                        "stargazers_count": 69000,
                        "language": "Swift",
                        "topics": ["swift", "apple", "programming-language"] // 故意设置错误的key用于测试
                    ]
                ]
            ])
        }
        let mockResponse = RepositoryListResponse(json: mockRespJSON)
        
        mockNetworkService.mockRepositoryListResponse = .success(mockResponse!)
        
        // 执行测试
        let result = try await githubService.getTrendingRepositories(days: 30, page: 1, perPage: 20)
        
        // 验证结果
        XCTAssertEqual(result.totalCount, 120, "热门仓库总数应为120")
        XCTAssertEqual(result.items.first?.owner.login, "facebook", "仓库名称不匹配")
        XCTAssertTrue(
            mockNetworkService.lastRequestURL?.absoluteString.contains("search/repositories") ?? false,
            "请求URL应包含搜索路径"
        )
    }
    
    /// 测试仓库搜索功能
    func testSearchRepositories() async throws {
        // 准备模拟数据
        let respJSONDict: [String: Any] = [
            "totalCount": 1,
            "incomplete_results": false,
            "items": [[
                "id": 2,
                "name": "Alamofire",
                "owner": [
                    "id": 100,
                    "login": "Alamofire",
                    "avatar_url": "https://avatars.githubusercontent.com/u/135057108?v=4"
                ],
                "language": "Swift",
                "description": "UI framework for Swift",
                "stargazers_count": 60000,
                "open_issues_count": 500,
                "forks_count": 3000,
                "created_at": "2025-08-23T00:17:42Z",
                "updated_at": "2025-08-23T00:18:42Z",
                "pushed_at": "2025-08-23T00:19:42Z"
            ]]
        ]
        let mockResponse = RepositoryListResponse(json: JSON(respJSONDict))
        
        mockNetworkService.mockRepositoryListResponse = .success(mockResponse!)
        
        // 执行测试
        let result = try await githubService.searchRepositories(query: "alamofire", page: 1, perPage: 20)
        
        // 验证结果
        XCTAssertEqual(result.items.count, 1, "搜索结果应返回1条数据")
        XCTAssertTrue(
            mockNetworkService.lastRequestURL?.absoluteString.contains("q=alamofire") ?? false,
            "搜索参数应包含关键词"
        )
    }
    
    /// 测试无效搜索关键词处理
    func testSearchWithEmptyQuery() async {
        do {
            _ = try await githubService.searchRepositories(query: "", page: 1, perPage: 20)
            XCTFail("空关键词应抛出错误")
        } catch GitHubError.invalidQuery {
            // 预期的错误，测试通过
        } catch {
            XCTFail("应抛出invalidQuery错误，实际抛出: \(error)")
        }
    }
    
    /// 测试网络错误处理
    func testNetworkErrorHandling() async {
        mockNetworkService.mockRepositoryListResponse = .failure(NetworkError.invalidURL)
        
        do {
            _ = try await githubService.getTrendingRepositories(days: 30, page: 1, perPage: 20)
            XCTFail("无效URL应抛出错误")
        } catch GitHubError.networkError(let error) {
            XCTAssertEqual(error, NetworkError.invalidURL, "错误类型不匹配")
        } catch {
            XCTFail("应抛出networkError，实际抛出: \(error)")
        }
    }
}

// 网络服务模拟类（适配XCTest）
class MockNetworkService: NetworkServiceProtocol {
    // 模拟仓库列表响应
    var mockRepositoryListResponse: Result<RepositoryListResponse, Error>?
    // 模拟用户响应
    var mockUserResponse: Result<User, Error>?
    // 模拟仓库数组响应
    var mockRepositoriesResponse: Result<[Repository], Error>?
    // 记录最后请求的URL
    var lastRequestURL: URL?
    
    func request<T>(url: String, method: HTTPMethod, params: Alamofire.Parameters?, headers: Alamofire.HTTPHeaders?) async throws -> T where T : SwiftyJSONParsable {
        // 记录请求URL
        lastRequestURL = URL(string: url)
        
        // 根据返回类型返回对应模拟数据
        if T.self == RepositoryListResponse.self, let response = mockRepositoryListResponse as? Result<T, Error> {
            return try response.get()
        } else if T.self == User.self, let response = mockUserResponse as? Result<T, Error> {
            return try response.get()
        } else {
            throw NetworkError.unknown(error: NSError(domain: "Mock", code: -1))
        }
    }
    
    func requestArray<T>(url: String, method: HTTPMethod, params: Parameters?, headers: HTTPHeaders?) async throws -> [T] where T : SwiftyJSONParsable {
        lastRequestURL = URL(string: url)
        
        if [T].self == [Repository].self, let response = mockRepositoriesResponse as? Result<T, Error> {
            return try response.get() as! [T]
        } else {
            throw NetworkError.unknown(error: NSError(domain: "Mock", code: -1))
        }
    }
    
    func requestPublisher<T>(url: String, method: HTTPMethod, params: Alamofire.Parameters?, headers: Alamofire.HTTPHeaders?) -> AnyPublisher<T, any Error> where T : SwiftyJSONParsable {
        lastRequestURL = URL(string: url)
        return Fail(error: NetworkError.unknown(error: NSError(domain: "Mock", code: -1))).eraseToAnyPublisher()
    }
    
    func downloadImageData(from urlString: String) async throws -> Data {
        return Data()
    }
}
