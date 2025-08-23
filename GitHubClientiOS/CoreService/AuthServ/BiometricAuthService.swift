//
//  BioAuthService.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import LocalAuthentication

/// 本地生物识别服务实现
class BiometricAuthService: BiometricAuthServiceProtocol {
    /// 单例实例
    static let shared: BiometricAuthServiceProtocol = BiometricAuthService()
    
    private let context: LAContext
    
    init(context: LAContext = LAContext()) {
        self.context = context
    }
    
    /// BiometricAuthProtocol
    
    /// 检查设备支持的生物识别类型
    func getBiometricType() -> BiometricType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return .none
        }
    }
    
    /// 检查生物识别是否可用
    func isBiometricAvailable() -> Bool {
        return getBiometricType() != .none
    }
    
    /// 进行生物识别验证
    func doBiometricAuth(reason: String) async throws -> Bool {
        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        var error: NSError?
        
        // 首先检查是否可以进行生物识别验证
        guard context.canEvaluatePolicy(policy, error: &error) else {
            throw mapLAErrorToBiometricError(error)
        }
        
        // 执行生物识别验证
        do {
            let success = try await context.evaluatePolicy(
                policy,
                localizedReason: reason
            )
            return success
        } catch let laError as LAError {
            throw mapLAErrorToBiometricError(laError)
        } catch {
            throw BiometricAuthError.unknownError
        }
    }
    
    /// 将LAError转换为自定义的BiometricAuthError
    private func mapLAErrorToBiometricError(_ error: Error?) -> BiometricAuthError {
        guard let laError = error as? LAError else {
            return .unknownError
        }
        
        switch laError.code {
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockedOut
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCanceled
        case .systemCancel:
            return .systemCanceled
        case .appCancel:
            return .appCanceled
        case .invalidContext:
            return .invalidContext
        default:
            return .unknownError
        }
    }
}

