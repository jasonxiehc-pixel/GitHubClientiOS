//
//  ErrorWrap.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import SwiftUI

/// 错误包装器，用于SwiftUI中展示错误信息
struct ErrorWrap: Identifiable {
    let id = UUID()
    let error: Error
    let title: String
    let message: String
    
    // MARK: - 初始化方法
    
    /// 使用Error初始化
    init(
        error: Error,
        title: String = "操作失败"
    ) {
        self.error = error
        self.title = title
        self.message = error.localizedDescription
    }
    
    /// 使用本地化描述初始化
    init(
        localizedDescription: String,
        title: String = "操作失败"
    ) {
        self.error = NSError(
            domain: "CustomError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: localizedDescription]
        )
        self.title = title
        self.message = localizedDescription
    }
    
    // MARK: - 便捷构造方法
    
    /// 创建网络错误
    static func networkError(
        localizedDescription: String = "网络连接失败，请检查网络设置"
    ) -> ErrorWrap {
        ErrorWrap(
            localizedDescription: localizedDescription,
            title: "网络错误"
        )
    }
    
    /// 创建认证错误
    static func authError(
        localizedDescription: String = "认证失败，请重新登录"
    ) -> ErrorWrap {
        ErrorWrap(
            localizedDescription: localizedDescription,
            title: "认证错误"
        )
    }
    
    /// 创建数据加载错误
    static func dataLoadingError(
        localizedDescription: String = "数据加载失败，请稍后重试"
    ) -> ErrorWrap {
        ErrorWrap(
            localizedDescription: localizedDescription,
            title: "加载失败"
        )
    }
}

// MARK: - SwiftUI视图扩展
extension View {
    /// 显示错误弹窗
    func errorAlert(for error: Binding<ErrorWrap?>) -> some View {
        alert(item: error) { wrap in
            Alert(
                title: Text(wrap.title),
                message: Text(wrap.message),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    /// 显示带重试按钮的错误弹窗
    func errorAlertWithRetry(
        for error: Binding<ErrorWrap?>,
        retryAction: @escaping () -> Void
    ) -> some View {
        alert(item: error) { wrap in
            Alert(
                title: Text(wrap.title),
                message: Text(wrap.message),
                primaryButton: .default(Text("重试"), action: retryAction),
                secondaryButton: .cancel()
            )
        }
    }
}

