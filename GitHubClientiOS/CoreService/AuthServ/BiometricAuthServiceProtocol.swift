//
//  BioAuthServiceProtocol.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import LocalAuthentication

/// 生物识别类型
enum BiometricType {
    case none
    case touchID
    case faceID
}

/// 生物识别错误类型
enum BiometricAuthError: Error, LocalizedError {
    case notAvailable
    case notEnrolled
    case lockedOut
    case authenticationFailed
    case userCanceled
    case systemCanceled
    case appCanceled
    case invalidContext
    case unknownError
    
    // protocol LocalizedError
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return NSLocalizedString("设备不支持生物识别", comment: "")
        case .notEnrolled:
            return NSLocalizedString("未设置生物识别", comment: "")
        case .lockedOut:
            return NSLocalizedString("生物识别已锁定，请使用密码解锁", comment: "")
        case .authenticationFailed:
            return NSLocalizedString("生物识别验证失败", comment: "")
        case .userCanceled:
            return NSLocalizedString("用户取消了生物识别", comment: "")
        case .systemCanceled:
            return NSLocalizedString("系统取消了生物识别", comment: "")
        case .appCanceled:
            return NSLocalizedString("应用取消了生物识别", comment: "")
        case .invalidContext:
            return NSLocalizedString("生物识别上下文无效", comment: "")
        case .unknownError:
            return NSLocalizedString("生物识别发生未知错误", comment: "")
        }
    }
}

/// 生物识别认证协议
protocol BiometricAuthServiceProtocol {
    /// 检查设备支持的生物识别类型
    func getBiometricType() -> BiometricType
    
    /// 检查生物识别是否可用
    func isBiometricAvailable() -> Bool
    
    /// 进行生物识别验证
    /// - Parameter reason: 向用户说明为什么需要生物识别的原因
    /// - Returns: 验证是否成功
    func doBiometricAuth(reason: String) async throws -> Bool
}

