//
//  NetworkServiceProtocol.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import Alamofire
import Combine

/// 网络服务协议
protocol NetworkServiceProtocol {
    /// 使用协程发送网络请求
    /// - Parameters:
    ///   - url: 请求URL
    ///   - method: HTTP方法
    ///   - params: 请求参数
    ///   - headers: 请求头
    ///   - decoder: 用于解码响应数据的解码器
    /// - Returns: 解码后的响应模型
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod,
        params: Parameters?,
        headers: HTTPHeaders?,
        decoder: JSONDecoder
    ) async throws -> T
    
    /// 使用Combine发送网络请求
    func requestPublisher<T: Decodable>(
        url: String,
        method: HTTPMethod,
        params: Parameters?,
        headers: HTTPHeaders?,
        decoder: JSONDecoder
    ) -> AnyPublisher<T, Error>
    
    /// 下载图片数据
    /// - Parameter url: 图片URL
    /// - Returns: 图片数据
    func downloadImageData(from url: String) async throws -> Data
}
