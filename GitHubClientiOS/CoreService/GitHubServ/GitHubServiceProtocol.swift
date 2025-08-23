//
//  GitHubServiceProtocol.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation

/// GitHub服务协议
protocol GitHubServiceProtocol {
    /// 获取热门仓库
    func getTrendingRepositories(days: Int, page: Int, perPage: Int) async throws -> RepositoryListResponse
    
    /// 搜索仓库
    func searchRepositories(query: String, page: Int, perPage: Int) async throws -> RepositoryListResponse
    
    /// 获取用户仓库
    func getUserRepositories(username: String, page: Int, perPage: Int) async throws -> [Repository]
    
    /// 获取当前登录用户的仓库
    func getCurrentUserRepositories(page: Int, perPage: Int) async throws -> [Repository]
    
    /// 获取用户资料
    func getUserProfile(username: String) async throws -> User
    
    /// 获取当前登录用户的资料
    func getCurrentUserProfile() async throws -> User
}

