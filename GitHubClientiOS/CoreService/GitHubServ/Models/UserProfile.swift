//
//  UserProfile.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation

/// 用户资料完整模型，整合用户基本信息和相关数据
struct UserProfile {
    let id: Int
    let basicInfo: UserBasicInfo
    let stats: UserStats
    let organizations: [Organization]?
    let recentRepositories: [Repository]?
    let starredRepositories: [Repository]?
    
    /// 从基础用户信息初始化
    init(from user: User) {
        self.id = user.id
        self.basicInfo = UserBasicInfo(from: user)
        self.stats = user.toStats
        self.organizations = nil
        self.recentRepositories = nil
        self.starredRepositories = nil
    }
    
    /// 完整初始化方法
    init(
        id: Int,
        basicInfo: UserBasicInfo,
        stats: UserStats,
        organizations: [Organization]?,
        recentRepositories: [Repository]?,
        starredRepositories: [Repository]?
    ) {
        self.id = id
        self.basicInfo = basicInfo
        self.stats = stats
        self.organizations = organizations
        self.recentRepositories = recentRepositories
        self.starredRepositories = starredRepositories
    }
}

/// 用户基本信息模型
struct UserBasicInfo: Codable {
    let login: String
    let name: String?
    let avatarUrl: String
    let bio: String?
    let email: String?
    let website: String?
    let company: String?
    let createdAt: String?
    let updatedAt: String?
    let htmlUrl: String
    let twitterUsername: String?
    
    /// 从User初始化
    init(from user: User) {
        self.login = user.login
        self.name = nil
        self.avatarUrl = user.avatarUrl
        self.bio = nil
        self.email = nil
        self.website = nil
        self.company = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.htmlUrl = user.htmlUrl
        self.twitterUsername = nil
    }
    
    /// 完整初始化方法
    init(
        login: String,
        name: String?,
        avatarUrl: String,
        bio: String?,
        email: String?,
        website: String?,
        company: String?,
        createdAt: String,
        updatedAt: String,
        htmlUrl: String,
        twitterUsername: String?
    ) {
        self.login = login
        self.name = name
        self.avatarUrl = avatarUrl
        self.bio = bio
        //self.location = location
        self.email = email
        self.website = website
        self.company = company
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.htmlUrl = htmlUrl
        self.twitterUsername = twitterUsername
    }
}

/// 组织模型
struct Organization: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
    let description: String?
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case description
        case htmlUrl = "html_url"
    }
}

/// 用户仓库统计细分模型
struct UserRepositoryStats: Codable {
    let total: Int
    let privateCount: Int
    let publicCount: Int
    let mostUsedLanguages: [LanguageUsage]
    let recentRepositories: [Repository]
}

/// 语言使用统计模型
struct LanguageUsage: Codable, Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
    let color: String?
    
    init(name: String, percentage: Double, color: String?) {
        self.name = name
        self.percentage = percentage
        self.color = color
    }
}

// MARK: - 扩展与辅助方法

extension UserProfile {
    /// 加入组织数据
    func withOrganizations(_ organizations: [Organization]) -> UserProfile {
        UserProfile(
            id: id,
            basicInfo: basicInfo,
            stats: stats,
            organizations: organizations,
            recentRepositories: recentRepositories,
            starredRepositories: starredRepositories
        )
    }
    
    /// 加入最近仓库数据
    func withRecentRepositories(_ repositories: [Repository]) -> UserProfile {
        UserProfile(
            id: id,
            basicInfo: basicInfo,
            stats: stats,
            organizations: organizations,
            recentRepositories: repositories,
            starredRepositories: starredRepositories
        )
    }
    
    /// 加入收藏仓库数据
    func withStarredRepositories(_ repositories: [Repository]) -> UserProfile {
        UserProfile(
            id: id,
            basicInfo: basicInfo,
            stats: stats,
            organizations: organizations,
            recentRepositories: recentRepositories,
            starredRepositories: repositories
        )
    }
}

extension UserBasicInfo {
//    /// 用户注册时间（格式化）
//    var memberSinceText: String {
//        let joinDate = createdAt.toLocalDateString()
//        return String(format: NSLocalizedString("加入于 %@", comment: ""), joinDate)
//    }
    
    /// 显示名称（优先显示name，否则显示login）
    var displayName: String {
        name ?? login
    }
    
    /// 是否有个人简介
    var hasBio: Bool {
        bio?.isEmpty == false && bio != nil
    }
}

extension Organization {
    /// 组织显示名称
    var displayName: String {
        login
    }
}

