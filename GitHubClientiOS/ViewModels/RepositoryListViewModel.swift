//
//  RepositoryListViewModel.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import SwiftUI

class RepositoryListViewModel: ObservableObject {
    @Published var trendingRepositories: [Repository] = []
    @Published var searchResults: [Repository] = []
    @Published var userRepositories: [Repository] = []
    @Published var currentUserRepositories: [Repository] = []
    
    @Published var isLoading: Bool = false
    @Published var hasMoreData: Bool = true
    
    @Published var errorMessage: ErrorWrap?
    @Published var currentPage: Int = 1
    
    private let githubService: GitHubServiceProtocol
    private let pageSize: Int = 20
    
    init(githubService: GitHubServiceProtocol = GitHubService.shared) {
        self.githubService = githubService
    }
    
    // 加载热门仓库 - 未登录可访问
    func loadTrendingRepositories(since: String, page: Int = 1, resetResults: Bool = true) {
        isLoading = true
        
        let timeframes = [
            "daily": 1,
            "weekly": 7,
            "monthly": 30
        ]
        Task {
            do {
                let response = try await githubService.getTrendingRepositories(
                    days: timeframes[since] ?? 30,
                    page: page,
                    perPage: pageSize
                )
                
                DispatchQueue.main.async {
                    if resetResults {
                        self.trendingRepositories = response.items
                    } else {
                        self.trendingRepositories.append(contentsOf: response.items)
                    }
                    
                    self.currentPage = page
                    self.hasMoreData = response.items.count == self.pageSize
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
    
    // 搜索仓库 - 未登录可访问
    func searchRepositories(query: String, page: Int = 1, resetResults: Bool = true) {
        guard !query.isEmpty else {
            if resetResults {
                searchResults = []
            }
            return
        }
        isLoading = true
        
        Task {
            do {
                let response = try await githubService.searchRepositories(
                    query: query,
                    page: page,
                    perPage: pageSize
                )
                
                DispatchQueue.main.async {
                    if resetResults {
                        self.searchResults = response.items
                    } else {
                        self.searchResults.append(contentsOf: response.items)
                    }
                    
                    self.currentPage = page
                    self.hasMoreData = response.items.count == self.pageSize
                    self.isLoading = false
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.errorMessage = ErrorWrap(localizedDescription: error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    // 加载更多搜索结果
    func loadMoreSearchResults(query: String) {
        guard !isLoading && hasMoreData else { return }
        searchRepositories(query: query, page: currentPage + 1, resetResults: false)
    }
    
    // 获取指定用户的仓库
    func loadUserRepositories(username: String, page: Int = 1, resetResults: Bool = true) {
        isLoading = true
        Task {
            do {
                let repositories = try await githubService.getUserRepositories(
                    username: username,
                    page: page,
                    perPage: pageSize
                )
                
                DispatchQueue.main.async {
                    if resetResults {
                        self.userRepositories = repositories
                    } else {
                        self.userRepositories.append(contentsOf: repositories)
                    }
                    
                    self.currentPage = page
                    self.hasMoreData = repositories.count == self.pageSize
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
    
    // 获取当前登录用户的仓库
    func loadCurrentUserRepositories(page: Int = 1, resetResults: Bool = true) {
        isLoading = true
        Task {
            do {
                let repositories = try await githubService.getCurrentUserRepositories(
                    page: page,
                    perPage: pageSize
                )
                
                DispatchQueue.main.async {
                    if resetResults {
                        self.currentUserRepositories = repositories
                    } else {
                        self.currentUserRepositories.append(contentsOf: repositories)
                    }
                    
                    self.currentPage = page
                    self.hasMoreData = repositories.count == self.pageSize
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
}

