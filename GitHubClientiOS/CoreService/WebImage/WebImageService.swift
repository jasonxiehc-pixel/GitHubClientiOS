//
//  WebImageService.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import SwiftUI
import Kingfisher

// 定义带泛型返回值的协议
protocol WebImageServiceProtocol {
    // 使用泛型T作为返回值，约束为View
    func loadImage<T: View>(from imgURL: URL?, placeholder: some View) async -> T
//    associatedtype ImageView: View
//    func loadImage(from imgURL: URL?, placeholder: some View) -> ImageView
}

class WebImageService {
    static let shared = WebImageService()
    private init() {} // 确保单例安全
    
    /*
    // 明确指定泛型T为Kingfisher的KFImage相关视图类型
    @MainActor
    func loadImage<T>(from imgURL: URL?, placeholder: some View) -> T where T : View {
        // 将KFImage包装为AnyView以满足泛型返回要求
        AnyView(
            KFImage(imgURL)
                .placeholder { placeholder }
                .resizable()
                .scaledToFit()
        ) as! T
    }
     */
    // 无需泛型，直接返回具体视图类型（编译器可推断关联类型）
    @MainActor func loadImage(from imgURL: URL?, placeholder: some View) -> some View {
        KFImage(imgURL)
            .placeholder { placeholder }
            .resizable()
            .scaledToFit()
    }
}

// 自定义SwiftUI视图，简化图片加载
struct WebImageView: View {
    let imgURL: URL?
    let placeholder: AnyView
    
    private let downloader: WebImageService = WebImageService.shared
    
    init(
        imgURL: URL?,
        placeholder: AnyView
    ) {
        self.imgURL = imgURL
        self.placeholder = placeholder
    }
    
    var body: some View {
        downloader.loadImage(from: imgURL, placeholder: placeholder)
    }
}
