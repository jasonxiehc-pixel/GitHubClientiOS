//
//  Repository.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import SwiftyJSON

struct Repository: Identifiable, SwiftyJSONParsable {
    let id: Int
    let name: String
    let owner: User
    let language: String
    let description: String
    let stargazersCount: Int
    let openIssuesCount: Int
    let forksCount: Int
    let createdAt, updatedAt, pushedAt: Date
    
    init?(json: JSON) {
        // 只解析需要的字段，忽略其他字段（如 owner、created_at 等）
        guard let id = json["id"].int else { return nil } // 必选字段，缺失则返回 nil
        self.id = id
        
        // 可选字段，使用默认值（如空字符串）处理缺失情况
        name = json["name"].stringValue // 即使字段缺失，也返回默认空字符串
        language = json["language"].stringValue
        description = json["description"].string ?? "" // 可能为 nil
        stargazersCount = json["stargazers_count"].intValue // 数字字段默认 0
        openIssuesCount = json["open_issues_count"].intValue
        forksCount = json["forks_count"].intValue
        
        // 解析嵌套对象（如 owner 字段，需 User 也支持 SwiftyJSON 解析）
        guard let owner = User(json: json["owner"]) else { return nil }
        self.owner = owner
        
        // 解析日期字段（SwiftyJSON 需配合日期格式化）
        let dateFormatter = ISO8601DateFormatter()
        createdAt = json["created_at"].string.flatMap { dateFormatter.date(from: $0) } ?? Date()
        updatedAt = json["updated_at"].string.flatMap { dateFormatter.date(from: $0) } ?? Date()
        pushedAt = json["pushed_at"].string.flatMap { dateFormatter.date(from: $0) } ?? Date()
    }
}

/// 仓库列表响应模型（用于搜索接口）
struct RepositoryListResponse: SwiftyJSONParsable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]
    
    init?(json: JSON) {
        // 只解析 items 数组，忽略 total_count、incomplete_results 等字段
        totalCount = json["total_count"].intValue
        incompleteResults = json["incomplete_results"].boolValue
        
        let itemsJSON = json["items"].arrayValue // 获取数组，空数组为默认值
        self.items = itemsJSON.compactMap { Repository(json: $0) } // 过滤无效数据
    }
}
