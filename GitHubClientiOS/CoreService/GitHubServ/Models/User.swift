//
//  User.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import SwiftyJSON

struct User: Identifiable, SwiftyJSONParsable {
    let id: Int
    let login: String
    let avatarUrl: String

    init?(json: JSON) {
        guard let id = json["id"].int else { return nil }
        self.id = id
        
        self.login = json["login"].stringValue
        self.avatarUrl = json["avatar_url"].stringValue
    }
}
