//
//  ThemeManager.swift
//  GitHubClientiOS
//
//  Created by xiehanchao on 2025/8/22.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    
    init() {
        // 初始化为系统默认
        colorScheme = nil
    }
    
    func toggleTheme() {
        if colorScheme == .light {
            colorScheme = .dark
        }
        else if colorScheme == .dark {
            colorScheme = nil // 系统默认
        }
        else {
            colorScheme = .light
        }
    }
}

