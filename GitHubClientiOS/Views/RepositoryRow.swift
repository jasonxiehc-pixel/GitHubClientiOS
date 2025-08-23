//
//  RepositoryRow.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI

/// 仓库列表项组件，用于在列表中展示GitHub仓库信息
struct RepositoryRow: View {
    let repository: Repository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 仓库名称和所有者
            HStack(alignment: .center, spacing: 4) {
                Text(repository.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("仓库标题")
                
                Text("/")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(repository.owner.login)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 仓库描述
            if !repository.description.isEmpty {
                Text(repository.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .accessibilityIdentifier("repositoryDesc")
            }
            
            // 仓库统计信息
            HStack(spacing: 16) {
                // 编程语言
                HStack(spacing: 4) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(languageColor(for: repository.language))
                    Text(repository.language)
                        .font(.caption)
                }
                
                // 星标数量
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text(formatNumber(repository.stargazersCount))
                        .font(.caption)
                }
                
                // 分支数量
                HStack(spacing: 4) {
                    Image(systemName: "tuningfork")
                        .font(.system(size: 12))
                    Text(formatNumber(repository.forksCount))
                        .font(.caption)
                }
                
                // 开放问题数量
                if repository.openIssuesCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12))
                        Text(formatNumber(repository.openIssuesCount))
                            .font(.caption)
                    }
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 辅助方法
    
    /// 格式化数字（如1k, 2.5k）
    private func formatNumber(_ number: Int) -> String {
        switch number {
        case 1000..<1000000:
            return String(format: "%.1fk", Double(number) / 1000)
        case 1000000...:
            return String(format: "%.1fm", Double(number) / 1000000)
        default:
            return String(number)
        }
    }
    
    /// 根据编程语言返回对应的颜色
    private func languageColor(for language: String) -> Color {
        switch language.lowercased() {
        case "swift":
            return .orange
        case "objective-c":
            return .blue
        case "java":
            return .red
        case "kotlin":
            return .purple
        case "python":
            return .yellow
        case "javascript", "typescript":
            return .yellow
        case "ruby":
            return .red
        case "go":
            return .blue
        case "c", "c++", "c#":
            return .green
        case "php":
            return .purple
        default:
            return .gray
        }
    }
}
/*
// 预览
struct RepositoryRow_Previews: PreviewProvider {
    static var previews: some View {
        // 创建示例仓库数据
        let sampleOwner = User(
            id: 1,
            login: "apple",
            avatarUrl: "https://avatars.githubusercontent.com/u/10639145?v=4",
            name: "Apple Inc.",
            email: "@apple.com",
            bio: nil,
            publicRepos: 10000,
            followers: 100000,
            following: 0,
            htmlUrl: "https://github.com/apple",
            createdAt: "2020-12-10",
            updatedAt: "2020-12-10"
        )
        
        let sampleRepo = Repository(
            id: 1,
            name: "swift",
            fullName: "apple/swift",
            description: "The Swift Programming Language",
            owner: sampleOwner,
            stargazersCount: 67800,
            openIssuesCount: 345,
            watchersCount: 67800,
            forksCount: 14500,
            language: "Swift",
            htmlUrl: "https://github.com/apple/swift",
            createdAt: "2020-12-10",
            updatedAt: "2020-12-10",
            pushedAt: "2020-12-10"
        )
        
        Group {
            RepositoryRow(repository: sampleRepo)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)
            
            RepositoryRow(repository: sampleRepo)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
 */

