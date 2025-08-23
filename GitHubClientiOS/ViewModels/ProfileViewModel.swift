//
//  ProfileViewModel.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: ErrorWrap?
    
    private let githubService: GitHubServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        githubService: GitHubServiceProtocol = GitHubService.shared,
        authService: AuthServiceProtocol = SecureAuthService.shared
    ) {
        self.githubService = githubService
        self.authService = authService
    }
    
    // 加载当前登录用户资料
    func loadCurrentUserProfile() {
        guard authService.isLoggedIn else { return }
        
        isLoading = true
        Task {
            do {
                let user = try await githubService.getCurrentUserProfile()
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = ErrorWrap(localizedDescription: error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    // 加载指定用户资料
    func loadUserProfile(username: String) {
        isLoading = true
        Task {
            do {
                let user = try await githubService.getUserProfile(username: username)
                DispatchQueue.main.async {
                    self.user = user
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = ErrorWrap(localizedDescription: error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    // 登出
    func logout() {
        do {
            try authService.logout()
            currentUser = nil
            NotificationCenter.default.post(name: .logoutSuccess, object: nil)
        } catch {
            errorMessage = ErrorWrap(localizedDescription: error.localizedDescription)
        }
    }
}

