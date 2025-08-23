//
//  Repository.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation

struct Repository: Identifiable, Codable {
    let id: Int
    let nodeId, name, fullName: String
    let itemPrivate: Bool
    let owner: User
    let htmlUrl: String
    let description: String
    let fork: Bool
    let url, forksUrl: String
    let keysUrl, collaboratorsUrl: String
    let teamsUrl, hooksUrl: String
    let issueEventsUrl: String
    let eventsUrl: String
    let assigneesUrl, branchesUrl: String
    let tagsUrl: String
    let blobsUrl, gitTagsUrl, gitRefsUrl, treesUrl: String
    let statusesUrl: String
    let languagesUrl, stargazersUrl, contributorsUrl, subscribersUrl: String
    let subscriptionUrl: String
    let commitsUrl, gitCommitsUrl, commentsUrl, issueCommentUrl: String
    let contentsUrl, compareUrl: String
    let mergesUrl: String
    let archiveUrl: String
    let downloadsUrl: String
    let issuesUrl, pullsUrl, milestonesUrl, notificationsUrl: String
    let labelsUrl, releasesUrl: String
    let deploymentsUrl: String
    let createdAt, updatedAt, pushedAt: Date
    let gitUrl, sshUrl: String
    let cloneUrl: String
    let svnUrl: String
    let homepage: String?
    let size, stargazersCount, watchersCount: Int
    let language: String?
    let hasIssues, hasProjects, hasDownloads, hasWiki: Bool
    let hasPages, hasDiscussions: Bool
    let forksCount: Int
    let mirrorUrl: String?
    let archived, disabled: Bool
    let openIssuesCount: Int
    let license: License?
    let allowForking, isTemplate, webCommitSignoffRequired: Bool
    let topics: [String]?
    let visibility: String
    let forks, openIssues, watchers: Int
    let defaultBranch: String
    let score: Int

    enum CodingKeys: String, CodingKey {
        case id
        case nodeId = "node_id"
        case name
        case fullName = "full_name"
        case itemPrivate = "private"
        case owner
        case htmlUrl = "html_url"
        case description, fork, url
        case forksUrl = "forks_url"
        case keysUrl = "keys_url"
        case collaboratorsUrl = "collaborators_url"
        case teamsUrl = "teams_url"
        case hooksUrl = "hooks_url"
        case issueEventsUrl = "issue_events_url"
        case eventsUrl = "events_url"
        case assigneesUrl = "assignees_url"
        case branchesUrl = "branches_url"
        case tagsUrl = "tags_url"
        case blobsUrl = "blobs_url"
        case gitTagsUrl = "git_tags_url"
        case gitRefsUrl = "git_refs_url"
        case treesUrl = "trees_url"
        case statusesUrl = "statuses_url"
        case languagesUrl = "languages_url"
        case stargazersUrl = "stargazers_url"
        case contributorsUrl = "contributors_url"
        case subscribersUrl = "subscribers_url"
        case subscriptionUrl = "subscription_url"
        case commitsUrl = "commits_url"
        case gitCommitsUrl = "git_commits_url"
        case commentsUrl = "comments_url"
        case issueCommentUrl = "issue_comment_url"
        case contentsUrl = "contents_url"
        case compareUrl = "compare_url"
        case mergesUrl = "merges_url"
        case archiveUrl = "archive_url"
        case downloadsUrl = "downloads_url"
        case issuesUrl = "issues_url"
        case pullsUrl = "pulls_url"
        case milestonesUrl = "milestones_url"
        case notificationsUrl = "notifications_url"
        case labelsUrl = "labels_url"
        case releasesUrl = "releases_url"
        case deploymentsUrl = "deployments_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case gitUrl = "git_url"
        case sshUrl = "ssh_url"
        case cloneUrl = "clone_url"
        case svnUrl = "svn_url"
        case homepage, size
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case language
        case hasIssues = "has_issues"
        case hasProjects = "has_projects"
        case hasDownloads = "has_downloads"
        case hasWiki = "has_wiki"
        case hasPages = "has_pages"
        case hasDiscussions = "has_discussions"
        case forksCount = "forks_count"
        case mirrorUrl = "mirror_url"
        case archived, disabled
        case openIssuesCount = "open_issues_count"
        case license
        case allowForking = "allow_forking"
        case isTemplate = "is_template"
        case webCommitSignoffRequired = "web_commit_signoff_required"
        case topics, visibility, forks
        case openIssues = "open_issues"
        case watchers
        case defaultBranch = "default_branch"
        case score
    }

}

/// 仓库列表响应模型（用于搜索接口）
struct RepositoryListResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

// 许可证模型（可选嵌套对象）
struct License: Codable {
    let key: String?
    let name: String?
    let spdxId: String?
    let url: String?
    let nodeId: String?
}
