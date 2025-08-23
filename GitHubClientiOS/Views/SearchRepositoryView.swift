//
//  SearchRepositoryView.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI

struct SearchRepositoryView: View {
    @EnvironmentObject var viewModel: RepositoryListViewModel
    @State private var searchQuery: String = "Swift"
    @State private var debounceTimer: Timer?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.searchResults.isEmpty {
                    ProgressView("搜索中...")
                }
                else if !viewModel.searchResults.isEmpty {
                    List {
                        ForEach(viewModel.searchResults) { repository in
                            RepositoryRow(repository: repository)
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .accessibilityIdentifier("SearchResultList")
                    .onAppear {
                        // 初始搜索
                        if !searchQuery.isEmpty && viewModel.searchResults.isEmpty {
                            performSearch()
                        }
                    }
                    .onChange(of: viewModel.currentPage) { _ in
                        // 加载更多
                        if viewModel.currentPage > 1 {
                            performSearch(resetResults: false)
                        }
                    }
                }
                else if !searchQuery.isEmpty {
                    Text("未找到匹配的仓库")
                        .foregroundColor(.secondary)
                }
                else {
                    Text("请输入关键词搜索仓库")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("搜索仓库")
            .searchable(text: $searchQuery, prompt: "搜索GitHub仓库...")
            .onChange(of: searchQuery) { newValue in
                // 防抖处理，避免频繁请求
                debounceTimer?.invalidate()
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    performSearch()
                }
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("搜索失败"),
                    message: Text(error.message),
                    primaryButton: .default(Text("取消")) {
                        viewModel.errorMessage = nil
                    },
                    secondaryButton: .default(Text("重试")) {
                        performSearch()
                    }
                )
            }
            .onAppear {
                performSearch()
            }
        }
    }
    
    // 执行搜索
    private func performSearch(resetResults: Bool = true) {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            if resetResults {
                viewModel.searchResults = []
            }
            return
        }
        
        viewModel.searchRepositories(
            query: searchQuery,
            page: resetResults ? 1 : viewModel.currentPage + 1,
            resetResults: resetResults
        )
    }
}

struct SearchRepositoryView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRepositoryView()
            .environmentObject(RepositoryListViewModel())
    }
}

