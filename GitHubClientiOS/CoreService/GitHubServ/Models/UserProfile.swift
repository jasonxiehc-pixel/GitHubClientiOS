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
    let organizations: [Organization]?
    let recentRepositories: [Repository]?
    let starredRepositories: [Repository]?
    
    /// 从基础用户信息初始化
    init(from user: User) {
        self.id = user.id
        self.basicInfo = UserBasicInfo(from: user)
        self.organizations = nil
        self.recentRepositories = nil
        self.starredRepositories = nil
    }
    
    /// 完整初始化方法
    init(
        id: Int,
        basicInfo: UserBasicInfo,
        organizations: [Organization]?,
        recentRepositories: [Repository]?,
        starredRepositories: [Repository]?
    ) {
        self.id = id
        self.basicInfo = basicInfo
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

