//
//  User.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let login: String
    let nodeId: String
    let avatarUrl: String
    let gravatarId: String
    let url, htmlUrl, followersUrl: String
    let followingUrl, gistsUrl, starredUrl: String
    let subscriptionsUrl, organizationsUrl, reposUrl: String
    let eventsUrl: String
    let receivedEventsUrl: String
    let type, userViewType: String
    let siteAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeId = "node_id"
        case avatarUrl = "avatar_url"
        case gravatarId = "gravatar_id"
        case url
        case htmlUrl = "html_url"
        case followersUrl = "followers_url"
        case followingUrl = "following_url"
        case gistsUrl = "gists_url"
        case starredUrl = "starred_url"
        case subscriptionsUrl = "subscriptions_url"
        case organizationsUrl = "organizations_url"
        case reposUrl = "repos_url"
        case eventsUrl = "events_url"
        case receivedEventsUrl = "received_events_url"
        case type
        case userViewType = "user_view_type"
        case siteAdmin = "site_admin"
    }
}

struct UserStats {
    let repositories: Int
    let followers: Int
    let following: Int
}

extension User {
    /// 转换为用户统计模型
    var toStats: UserStats {
        UserStats(
            repositories: 10,
            followers: 10,
            following: 10
        )
    }
}
