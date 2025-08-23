//
//  KeyChainService.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import Security

/// 钥匙串服务实现
final class KeychainService: KeychainServiceProtocol {
    /// 单例实例
    static let shared: KeychainServiceProtocol = KeychainService()
    
    /// 服务标识符，用于区分不同应用的钥匙串数据
    private let service: String
    
    /// 初始化钥匙串服务
    /// - Parameter service: 服务标识符，默认为应用的bundle identifier
    init(service: String = Bundle.main.bundleIdentifier ?? "com.githubclient.keychain") {
        self.service = service
    }
    
    /// 创建查询字典
    private func query(forKey key: String, withValue value: Data? = nil) -> [CFString: Any] {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]
        
        if let value = value {
            query[kSecValueData] = value
        }
        
        return query
    }
    
    /// 存储字符串值
    func setString(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        
        // 先尝试删除已存在的值
        do {
            try removeValue(forKey: key)
        }
        catch let error as KeychainError {
            if error != .itemNotFound {
                throw error
            }
        }
        catch {
            throw error
        }
        
        // 添加新值
        let query = query(forKey: key, withValue: data)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
    }
    
    func getString(forKey key: String) throws -> String? {
        var query = query(forKey: key)
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.decodingFailed
            }
            return String(data: data, encoding: .utf8)
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.from(status: status)
        }
    }
    
    /// 存储布尔值
    func setBool(_ value: Bool, forKey key: String) throws {
        var mutableValue = value
        // 正确获取内存缓冲区
        let data = Data(buffer: UnsafeBufferPointer(start: &mutableValue, count: 1))
        
        // 先尝试删除已存在的值
        do {
            try removeValue(forKey: key)
        }
        catch let error as KeychainError {
            if error != .itemNotFound {
                throw error
            }
        }
        catch {
            throw error
        }
        
        // 添加新值
        let query = query(forKey: key, withValue: data)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
    }
    
    /// 获取布尔值
    func getBool(forKey key: String) throws -> Bool? {
        var query = query(forKey: key)
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data, data.count == MemoryLayout<Bool>.size else {
                throw KeychainError.decodingFailed
            }
            
            var value: Bool = false
            _ = withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0) }
            return value
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.from(status: status)
        }
    }
    
    /// 删除指定键的值
    func removeValue(forKey key: String) throws {
        let query = query(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.from(status: status)
        }
    }
    
    /// 清空所有存储的值
    func clearAll() throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.from(status: status)
        }
    }
}

/// 钥匙串错误类型添加Equatable协议，解决比较问题
enum KeychainError: Error, LocalizedError, Equatable {
    case encodingFailed
    case decodingFailed
    case itemNotFound
    case duplicateItem
    case invalidData
    case accessDenied
    case other(status: OSStatus)
    
    /// 从状态码转换为错误类型
    static func from(status: OSStatus) -> KeychainError {
        switch status {
        case errSecSuccess:
            fatalError("成功状态不应转换为错误")
        case errSecItemNotFound:
            return .itemNotFound
        case errSecDuplicateItem:
            return .duplicateItem
        case errSecInvalidData:
            return .invalidData
        case errSecAuthFailed:
            return .accessDenied
        default:
            return .other(status: status)
        }
    }
    
    /// 本地化错误描述
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return NSLocalizedString("数据编码失败", comment: "")
        case .decodingFailed:
            return NSLocalizedString("数据解码失败", comment: "")
        case .itemNotFound:
            return NSLocalizedString("未找到指定项", comment: "")
        case .duplicateItem:
            return NSLocalizedString("该项已存在", comment: "")
        case .invalidData:
            return NSLocalizedString("无效的数据", comment: "")
        case .accessDenied:
            return NSLocalizedString("访问被拒绝", comment: "")
        case .other(let status):
            return String(format: NSLocalizedString("钥匙串错误 (状态码: %d)", comment: ""), status)
        }
    }
}
