//
//  NetworkService.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import Alamofire
import Combine
import SwiftyJSON

/// 基于Alamofire的网络服务实现
final class NetworkService: NetworkServiceProtocol {
    /// 单例实例
    static let shared: NetworkServiceProtocol = NetworkService()
    /// 私有初始化方法，确保单例
    private init() {}
    
    /// 发送网络请求并返回解码后的对象
    func request<T: SwiftyJSONParsable>(
        url: String,
        method: HTTPMethod = .get,
        params: Parameters? = nil,
        headers: HTTPHeaders? = nil
        //decoder: JSONDecoder = JSONDecoder()
    )
    async throws -> T {
        // 验证URL有效性
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        /*
        // 配置请求头，重点设置Accept
        let headers: HTTPHeaders = [
            //"Accept": "application/vnd.github.v3+json",
            "Accept": "application/json",
            "User-Agent": "HWClientiOS"
        ]
         */
        // 配置请求参数编码方式
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        // 执行请求并等待响应
        let response = await AF.request(
            url,
            method: method,
            parameters: params,
            encoding: encoding,
            headers: headers,
            requestModifier: { $0.timeoutInterval = 10 }
        )
        .validate() // 验证状态码 200...299
        .serializingData()
        .response
        
        // 处理响应结果
        switch response.result {
        case .success(let data):
            // 检查HTTP响应和状态码
            guard let httpResponse = response.response else {
                throw NetworkError.invalidResponse
            }
            
            // 特殊处理401未授权错误
            if httpResponse.statusCode == 401 {
                NotificationCenter.default.post(name: .unauthorized, object: nil)
                throw NetworkError.unauthorized
            }
            
            // 验证数据不为空
            guard !data.isEmpty else {
                throw NetworkError.emptyData
            }
            
            // 解码数据
            /*
            do {
                return try decoder.decode(T.self, from: data)
            }
            catch {
                throw NetworkError.decodingFailed(error: error)
            }
             */
            guard let result = T(json: JSON(data)) else {
                throw NetworkError.decodingFailed(error: NSError(
                    domain: "SwiftyJSON",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "JSON 解析失败"]
                ))
            }
            return result
            
        case .failure(let error):
            // 转换Alamofire错误并抛出
            throw NetworkError.from(error)
        }
    }
    
    /// 接口返回的是数组包字典的
    func requestArray<T>(
        url: String,
        method: HTTPMethod,
        params: Parameters?,
        headers: HTTPHeaders?
    )
    async throws -> [T] where T : SwiftyJSONParsable {
        // 验证URL有效性
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        // 配置请求参数编码方式
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        // 执行请求并等待响应
        let response = await AF.request(
            url,
            method: method,
            parameters: params,
            encoding: encoding,
            headers: headers,
            requestModifier: { $0.timeoutInterval = 10 }
        )
        .validate() // 验证状态码 200...299
        .serializingData()
        .response
        
        // 处理响应结果
        switch response.result {
        case .success(let data):
            // 检查HTTP响应和状态码
            guard let httpResponse = response.response else {
                throw NetworkError.invalidResponse
            }
            
            // 特殊处理401未授权错误
            if httpResponse.statusCode == 401 {
                NotificationCenter.default.post(name: .unauthorized, object: nil)
                throw NetworkError.unauthorized
            }
            
            // 验证数据不为空
            guard !data.isEmpty else {
                throw NetworkError.emptyData
            }
            
            // 解析数据
            let dJSON = JSON(data)
            // 将 JSON 数组转为 [T]
            let results = dJSON.arrayValue.compactMap { T(json: $0) }
            // 如果需要严格校验（不允许数组中有无效元素）
            if results.count != dJSON.arrayValue.count {
                throw NetworkError.decodingFailed(error: NSError(
                    domain: "SwiftyJSON",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "数组中包含无效元素"]
                ))
            }
            return results
            
        case .failure(let error):
            // 转换Alamofire错误并抛出
            throw NetworkError.from(error)
        }
    }
    
    /// 使用Combine发送网络请求
    func requestPublisher<T: SwiftyJSONParsable>(
        url: String,
        method: HTTPMethod = .get,
        params: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) -> AnyPublisher<T, Error> {
        // 验证URL有效性
        guard let url = URL(string: url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        // 配置请求参数编码方式
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        return AF.request(
            url,
            method: method,
            parameters: params,
            encoding: encoding,
            headers: headers,
            requestModifier: { $0.timeoutInterval = 10 }
        )
        .validate()
        .publishData()
        .tryMap { [weak self] response in
            guard let self = self else { throw NetworkError.unknown(error: NSError(domain: "NetworkService", code: -1)) }
            return try self.handleResponse(response)
        }
        .eraseToAnyPublisher()
    }
    
    /// 处理响应的通用方法
    private func handleResponse<T: SwiftyJSONParsable>(_ response: AFDataResponse<Data>) throws -> T {
        switch response.result {
        case .success(let data):
            // 检查HTTP响应和状态码
            guard let httpResponse = response.response else {
                throw NetworkError.invalidResponse
            }
            
            // 特殊处理401未授权错误 - 确保在主线程发送通知
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            
            // 验证数据不为空
            guard !data.isEmpty else {
                throw NetworkError.emptyData
            }
            
            // 解码数据
            guard let result = T(json: JSON(data)) else {
                throw NetworkError.decodingFailed(error: NSError(
                    domain: "SwiftyJSON",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "JSON 解析失败"]
                ))
            }
            return result
            
        case .failure(let error):
            // 转换Alamofire错误并抛出
            throw NetworkError.from(error)
        }
    }
    
    /// 下载图片数据
    func downloadImageData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // 执行图片下载请求
        let response = await AF.request(
            url,
            method: .get,
            requestModifier: { $0.timeoutInterval = 15 }
        )
        .validate()
        .serializingData()
        .response
        
        // 处理响应结果
        switch response.result {
        case .success(let data):
            guard let httpResponse = response.response,
                  200...299 ~= httpResponse.statusCode else {
                throw NetworkError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw NetworkError.emptyData
            }
            
            return data
            
        case .failure(let error):
            throw NetworkError.from(error)
        }
    }
}

/// 网络错误类型
enum NetworkError: Equatable, Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyData
    case decodingFailed(error: Error)
    case unauthorized
    case requestFailed(message: String)
    case serverError(code: Int)
    case networkFailure
    case unknown(error: Error)
    
    /// 从Alamofire错误转换
    static func from(_ afError: AFError) -> NetworkError {
        switch afError {
        case .invalidURL:
            return .invalidURL
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                if code == 401 {
                    return .unauthorized
                }
                return .serverError(code: code)
            }
            return .invalidResponse
        case .sessionTaskFailed(let error as NSError) where error.domain == NSURLErrorDomain:
            return .networkFailure
        case .sessionTaskFailed(let error):
            return .requestFailed(message: error.localizedDescription)
        case .parameterEncodingFailed, .responseSerializationFailed:
            return .requestFailed(message: afError.localizedDescription)
        default:
            return .unknown(error: afError)
        }
    }
    
    /// 本地化错误描述
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("无效的URL", comment: "")
        case .invalidResponse:
            return NSLocalizedString("无效的服务器响应", comment: "")
        case .emptyData:
            return NSLocalizedString("服务器返回空数据", comment: "")
        case .decodingFailed(let error):
            return String(format: NSLocalizedString("数据解析错误: %@", comment: ""), error.localizedDescription)
        case .unauthorized:
            return NSLocalizedString("未授权访问，请重新登录", comment: "")
        case .requestFailed(let message):
            return String(format: NSLocalizedString("请求失败: %@", comment: ""), message)
        case .serverError(let code):
            return String(format: NSLocalizedString("服务器错误，状态码: %d", comment: ""), code)
        case .networkFailure:
            return NSLocalizedString("网络连接失败，请检查网络设置", comment: "")
        case .unknown(let error):
            return String(format: NSLocalizedString("未知错误: %@", comment: ""), error.localizedDescription)
        }
    }
    
    // 实现Equatable协议
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.emptyData, .emptyData):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.networkFailure, .networkFailure):
            return true
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.requestFailed(let lhsMsg), .requestFailed(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// 通知扩展
extension Notification.Name {
    /// 未授权通知（401错误）
    static let unauthorized = Notification.Name("NetworkUnauthorized")
}
