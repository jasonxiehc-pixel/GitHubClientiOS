//
//  AsyncImageView.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI
import Kingfisher

/// 基于Kingfisher的异步图片加载组件
struct AsyncImageView: View {
    private let urlStr: String?
    private let placeholder: String
    private let errorIcon: String
    
    /// 主要初始化方法
    init(
        urlStr: String?,
        placeholder: String = "photo",
        errorIcon: String = "photo.slash"
    ) {
        self.urlStr = urlStr
        self.placeholder = placeholder
        self.errorIcon = errorIcon
    }
    
    /// 用于用户头像的便捷初始化
    init(
        urlStr: String?,
        avatarPlaceholder: String = "person.circle"
    ) {
        self.urlStr = urlStr
        self.placeholder = avatarPlaceholder
        self.errorIcon = "person.circle.slash"
    }
    
    var body: some View {
        KFImage(URL(string: urlStr ?? ""))
            .resizable()
            // 占位图设置
            .placeholder {
                Image(systemName: placeholder)
                    .foregroundColor(.secondary)
            }
            // 错误处理
            .onFailure { _ in
                Image(systemName: errorIcon)
                    .foregroundColor(.secondary)
            }
            // 缓存设置
            .cacheMemoryOnly()
            // 加载动画
            .fade(duration: 0.2)
            .scaledToFill()
    }
}

// MARK: - 预览
struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 普通图片
            AsyncImageView(
                urlStr: "https://avatars.githubusercontent.com/u/10639145?v=4"
            )
            .frame(width: 200, height: 200)
            .clipped()
            
            // 用户头像（圆形）
            AsyncImageView(
                urlStr: "https://avatars.githubusercontent.com/u/10639145?v=4",
                avatarPlaceholder: "person.circle"
            )
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .clipped()
            
            // 无效URL（显示错误图标）
            AsyncImageView(
                urlStr: "invalid_url"
            )
            .frame(width: 150, height: 150)
        }
    }
}
