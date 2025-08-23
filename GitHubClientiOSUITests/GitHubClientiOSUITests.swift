//
//  GitHubClientiOSUITests.swift
//  GitHubClientiOSUITests
//
//  Created by xiehanchao on 2025/8/22.
//

import XCTest
@testable import GitHubClientiOS

final class GitHubClientiOSUITests: XCTestCase {
    // 应用实例
    private var app: XCUIApplication!
    
    // 测试前的设置
    override func setUpWithError() throws {
        try super.setUpWithError()
        // 失败后立即停止，不继续执行
        continueAfterFailure = false
        // 初始化应用并启动
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"] // 可用于应用内区分测试环境
        app.launch()
    }
    
    // 测试后的清理
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // 测试Tab栏切换功能
    @MainActor
    func testTabBarNavigation() throws {
        // 验证初始Tab（热门仓库）
        let trendingTab = app.tabBars.buttons["热门"]
        XCTAssertTrue(trendingTab.exists)
        XCTAssertTrue(trendingTab.isSelected)
        
        // 切换到搜索Tab
        let searchTab = app.tabBars.buttons["搜索"]
        XCTAssertTrue(searchTab.exists)
        searchTab.tap()
        XCTAssertTrue(searchTab.isSelected)
        
        // 切换到我的Tab
        let profileTab = app.tabBars.buttons["我的"]
        XCTAssertTrue(profileTab.exists)
        profileTab.tap()
        XCTAssertTrue(profileTab.isSelected)
    }
    
    // 测试热门仓库列表加载
    @MainActor
    func testTrendingRepositoryList() throws {
        // 确保在热门仓库Tab
        app.tabBars.buttons["热门"].tap()
        
        // 验证列表视图存在
        let repoList = app.collectionViews["trendingRepoList"]
        XCTAssertTrue(repoList.waitForExistence(timeout: 5))
        
        // 验证加载指示器消失（数据加载完成）
        let activityIndicator = app.activityIndicators.firstMatch
        if activityIndicator.exists {
            XCTAssertFalse(activityIndicator.waitForExistence(timeout: 10))
        }
        
        // 验证至少有一个仓库项
        let firstRepoCell = repoList.cells.firstMatch
        XCTAssertTrue(firstRepoCell.waitForExistence(timeout: 5))
        
        // 点击第一个仓库，验证详情页跳转
        firstRepoCell.tap()
        let repoDetailTitle = app.navigationBars.firstMatch.staticTexts.firstMatch
        XCTAssertTrue(repoDetailTitle.exists)
        
        // 返回列表
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(repoList.exists)
    }
    
    // 测试搜索功能
    @MainActor
    func testRepositorySearch() throws {
        // 切换到搜索Tab
        app.tabBars.buttons["搜索"].tap()
        
        // 验证搜索框存在
        let searchField = app.searchFields["搜索GitHub仓库..."]
        XCTAssertTrue(searchField.exists)
        
        // 输入搜索关键词
        searchField.tap()
        searchField.typeText("RxSwift\n")
        
        // 验证搜索结果
        let resultList = app.collectionViews["SearchResultList"]
        XCTAssertTrue(resultList.waitForExistence(timeout: 5))
        
        // 验证结果不为空
        XCTAssertGreaterThan(resultList.cells.count, 0)
        
        // 验证结果包含关键词相关内容
        let firstResult = app.cells.firstMatch
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // 验证结果包含关键词相关内容
        XCTAssertTrue(firstResult.staticTexts.element(boundBy: 0).label.contains("RxSwift"))
    }
    
    // 测试未登录状态下的个人中心
    @MainActor
    func testProfileUnauthenticated() throws {
        // 切换到我的Tab
        app.tabBars.buttons["我的"].tap()
        
        // 验证登录按钮存在
        let loginButton = app.buttons["LoginPromptGitHubLogin"]
        XCTAssertTrue(loginButton.exists)
        XCTAssertEqual(loginButton.label, "使用GitHub账号登录")
        
        // 点击登录按钮（仅验证跳转，不实际登录）
        loginButton.tap()
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
    }
    
    // 测试应用启动性能
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // 测量启动时间
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
