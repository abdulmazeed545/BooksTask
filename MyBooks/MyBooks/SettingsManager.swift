//
//  SettingsManager.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    private let notificationsEnabledKey = "notificationsEnabled"
    private let themeKey = "selectedAppTheme"
    
    var notificationsEnabled: Bool {
            get {
                // Default to true if never set before
                if UserDefaults.standard.object(forKey: notificationsEnabledKey) == nil {
                    return true
                }
                return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: notificationsEnabledKey)
            }
        }
    
    var currentTheme: String {
        get {
            return UserDefaults.standard.string(forKey: themeKey) ?? "system"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: themeKey)
        }
    }
    
    private init() {
        // Initialize default values if not set
        if UserDefaults.standard.object(forKey: notificationsEnabledKey) == nil {
            notificationsEnabled = true
        }
        if UserDefaults.standard.object(forKey: themeKey) == nil {
            currentTheme = "system"
        }
    }
}
