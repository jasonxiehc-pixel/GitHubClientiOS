# HomeWork
本应用使用Swift+SwiftUI编写，利用 GitHub OAuth REST-API 获取GitHub的一些数据并展示。它允许游客进行搜索及GitHub账户+本地生物识别进行授权登录，登录后可以查看自己的仓库列表、个人信息等。

## 整体功能
- GitHub授权登录
— FaceID、TouchID的本地生物识别登录
- 搜索仓库，比如Swift关键字
- 最近1个月Star>5000+的热门仓库
- 浏览个人信息
- 浏览个人仓库

## 架构
该应用采用MVVM架构，响应式编程范式，面向协议编程；通过SwiftUI的声明式编程简洁地实现UI交互开发，业务逻辑通过双向事件流绑定实现数据通讯更新。事件流转的清晰、项目架构设计分为以下几个层级：

### 基础
使用CocoaPod进行三方库的接入&版本管理， 一步到位，后续迭代新增各类型的私有仓库扩展性高，维护成本低

### CoreService 核心服务层
通过Protocol实现接口访问与实现分离
- **SecureAuthService** 负责用户登录管理，封装GitHub账户授权登录+设备本地生物识别登录，使用KeyChain安全存储授权登录等私密重要信息并且不会因应用被卸载遭到删除
- **BiometricAuthService** 封装设备本地的生物识别信息完成验证登录
- **GitHubService** 封装GitHub API服务的具体实现
- **KeychainService** 封装钥匙串本地存储， 用于用户隐私数据本地缓存
- **NetworkService** 基于Alamofire实现网络服务封装， 通过使用try await/async协程开发避免异步回调地狱，代码简洁，层次清晰； 同时支持Combine的响应式接口请求是事件流绑定服务

### UI层 - SwiftUI构建
- **MainView:** 首页，分为 热门仓库，搜索仓库，我的 3个Tab，支持未登录浏览，不影响读取仓库的相关数据
- **TrendingRepositoryView:** 负责热门仓库列表数据的展示，默认展示30天内最热门(Star数>5000)仓库，与搜索仓库列表共用 RepositoryListViewModel
- **SearchRepositoryView:** 负责登录后的个人信息展示，对应的ProfileViewModel负责事件监听和UI交互
- **LoginView:** 负责授权登录+本地生物识别的UI交互展示
- **ProfileView:** 负责用户信息UI交互展示，已登录展示用户信息，未登录显示授权登录入口

### ViewModel
- **RepositoryListViewModel:** 负责热门&搜索仓库列表视图的数据管理及事件处理封装和TrendingRepositoryView+ SearchRepositoryView进行交互
- **AuthViewModel:** 负责用户授权登录+生物识别登录的事件处理调用及数据逻辑封装和MainView交互
- **ProfileViewModel:** 负责我的-用户信息视图的数据逻辑封装及事件处理，与ProfileView+MainView都有进行交互

### 数据层
- **User:** GitHub 授权用户的基本+详细信息数据模型
- **Repository:** GitHub 仓库列表信息数据模型

### 组件
- **RepositoryRow** 仓库列表数据展示用到的行组件
- **AsyncImageView** 基于KingFisher封装的图片异步加载组件

### Test
- **ClientTests**
- **ClientUITests**

## Tech Stack
- Swift
- SwiftUI
- Combine
- Kingfisher
- Alamofire
- KeyChain
- XCTest
- XCUITests


## Other

### Test

| HomeWorkTests | HomeWorkUITests |
| --- | :---: |
| <img src="Resource/Test/unit_test.jpg" width="500"> | <img src="Resource/Test/ui_test.jpg" width="500"> |

### Demo Video
![演示视频](Resource/Video/demo_video.mp4)

### UI Design
| Design | home | profile | logo |
| --- | :---: | ---: |---: |
| <img src="Resource/Design/design_overview_drawing.jpg" width="900"> | <img src="Resource/Design/design_overview_drawing.jpg" width="400"> | <img src="Resource/Design/design_overview_drawing.jpg" width="400"> |<img src="Resource/Design/design_overview_drawing.jpg" width="400"> |



### TestFlight
| App | Website | Local |
| --- | :---: | ---: |
| <img src="Resource/TestFlight/testFlight_app.jpg" width="500"> | <img src="Resource/TestFlight/testFlight_website.jpg" width="700"> | <img src="Resource/TestFlight/local_upload.jpg" width="700"> |


### Class Diagram

| View | ViewModel |
| --- | :---: |
| <img src="Resource/ClassDiagram/view.jpg" width="800"> | <img src="Resource/ClassDiagram/view_model_event.jpg" width="400"> |



