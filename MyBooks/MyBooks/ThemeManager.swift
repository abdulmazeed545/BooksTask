//
//  ThemeManager.swift
//  MyBooks
//
//  Created by Mazeed on 23/06/25.
//

import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
    
    func applyTheme() {
        let theme = SettingsManager.shared.currentTheme
        
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
            return
        }
        
        switch theme {
        case "Light":
            window.overrideUserInterfaceStyle = .light
        case "Dark":
            window.overrideUserInterfaceStyle = .dark
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}
