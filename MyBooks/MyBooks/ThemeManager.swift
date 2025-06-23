//
//  ThemeManager.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//

import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    private init() {}
    
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
    
    private let themeKey = "selectedAppTheme"
    
    var currentTheme: Theme {
        get {
            guard let savedTheme = UserDefaults.standard.string(forKey: themeKey),
                  let theme = Theme(rawValue: savedTheme) else {
                return .system
            }
            return theme
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            applyTheme()
        }
    }
    
    func applyTheme() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
            return
        }
        
        switch currentTheme {
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}
