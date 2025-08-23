//
//  TrendingRepositoryView.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/23.
//

import SwiftUI

struct TrendingRepositoryView: View {
    @EnvironmentObject var viewModel: RepositoryListViewModel
    @State private var selectedTimeframe: String = "monthly"
    
    let timeframes = [
        "daily": "今日",
        "weekly": "本周",
        "monthly": "本月"
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.trendingRepositories.isEmpty {
                    ProgressView("加载热门仓库...")
                } else if !viewModel.trendingRepositories.isEmpty {
                    List(viewModel.trendingRepositories) { repository in
                        RepositoryRow(repository: repository)
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Text("未找到热门仓库")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("热门仓库")
            .navigationBarItems(trailing: timeframePicker)
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("加载失败"),
                    message: Text(error.message),
                    primaryButton: .default(Text("取消")) {
                        viewModel.errorMessage = nil
                    },
                    secondaryButton: .default(Text("重试")) {
                        viewModel.loadTrendingRepositories(since: selectedTimeframe)
                    }
                )
            }
            .onAppear {
                if viewModel.trendingRepositories.isEmpty {
                    viewModel.loadTrendingRepositories(since: selectedTimeframe)
                }
            }
            .accessibilityIdentifier("trendingRepoList")
        }
    }
    
    // 时间范围选择器
    private var timeframePicker: some View {
        Picker("时间范围", selection: $selectedTimeframe) {
            ForEach(timeframes.keys.sorted(), id: \.self) { key in
                Text(timeframes[key] ?? key)
                    .tag(key)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: selectedTimeframe) { newValue in
            viewModel.loadTrendingRepositories(since: newValue)
        }
    }
}

struct TrendingRepositoryView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingRepositoryView()
            .environmentObject(RepositoryListViewModel())
    }
}

