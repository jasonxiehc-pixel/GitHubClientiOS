//
//  SearchViewModel.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import Foundation
import SwiftUI
import Combine

/// 搜索视图模型
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var repositories: [Repository] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showNoResults: Bool = false
    
    private let gitHubService: GitHubServiceProtocol
    private var currentPage: Int = 1
    private let perPage: Int = 15
    private var isSearching: Bool = false
    private var canLoadMore: Bool = true
    
    init(gitHubService: GitHubServiceProtocol = GitHubService.shared) {
        self.gitHubService = gitHubService
        setupSearchDebounce()
    }
    
    /// 设置搜索防抖
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.count >= 2 || text.isEmpty {
                    self.resetSearch()
                    if !text.isEmpty {
                        self.searchRepositories()
                    } else {
                        self.clearResults()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// 重置搜索状态
    private func resetSearch() {
        currentPage = 1
        canLoadMore = true
        repositories.removeAll()
    }
    
    /// 清除搜索结果
    private func clearResults() {
        repositories.removeAll()
        showNoResults = false
        errorMessage = nil
    }
    
    /// 搜索仓库
    func searchRepositories() {
        guard !isSearching, !searchText.isEmpty, canLoadMore else { return }
        
        isSearching = true
        isLoading = true
        errorMessage = nil
        showNoResults = false
        
        Task {
            do {
                let results = try await gitHubService.searchRepositories(
                    query: searchText,
                    page: currentPage,
                    perPage: perPage
                )
                
                await MainActor.run {
                    if currentPage == 1 {
                        repositories = results.items
                    } else {
                        repositories.append(contentsOf: results.items)
                    }
                    
                    canLoadMore = results.totalCount == perPage
                    currentPage += 1
                    showNoResults = repositories.isEmpty
                    isLoading = false
                    isSearching = false
                }
            }
            catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    isSearching = false
                }
            }
        }
    }
    
    /// 加载更多结果
    func loadMoreResults() {
        guard !isLoading, !searchText.isEmpty, canLoadMore else { return }
        searchRepositories()
    }
    
    /// 重试搜索
    func retry() {
        searchRepositories()
    }
}

