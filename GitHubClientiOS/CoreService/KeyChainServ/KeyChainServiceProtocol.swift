//
//  KeyChainServiceProtocol.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation

/// 钥匙串服务协议，定义安全存储数据的接口
protocol KeychainServiceProtocol {
    func setString(_ value: String, forKey key: String) throws
    
    func getString(forKey key: String) throws -> String?
    
    func setBool(_ value: Bool, forKey key: String) throws
    
    func getBool(forKey key: String) throws -> Bool?
    
    func removeValue(forKey key: String) throws
    
    func clearAll() throws
}
