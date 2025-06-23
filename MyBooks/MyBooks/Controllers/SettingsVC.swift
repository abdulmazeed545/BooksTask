//
//  SettingsVC.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//
import UIKit

class SettingsViewController: UITableViewController {
    
    private enum Section: Int, CaseIterable {
          case theme, notifications
      }
      
      private let settingsManager = SettingsManager.shared
      private let themes = ThemeManager.Theme.allCases
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        NotificationManager.shared.checkAuthorization { value in
            
        }
    }
    
    private func setupView() {
           title = "Settings"
           navigationController?.navigationBar.prefersLargeTitles = true
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "themeCell")
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "switchCell")
           tableView.separatorStyle = .singleLine
       }
    
    // MARK: - Table View Data Source
       
       override func numberOfSections(in tableView: UITableView) -> Int {
           return Section.allCases.count
       }
       
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           guard let section = Section(rawValue: section) else { return 0 }
           
           switch section {
           case .theme: return themes.count
           case .notifications: return 1
           }
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let section = Section(rawValue: indexPath.section) else {
               return UITableViewCell()
           }
           
           switch section {
           case .theme:
               let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)
               let theme = themes[indexPath.row]
               cell.textLabel?.text = theme.rawValue
               cell.accessoryType = settingsManager.currentTheme == theme.rawValue ? .checkmark : .none
               return cell
               
           case .notifications:
               let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath)
               cell.textLabel?.text = "Enable Notifications"
               
               let switchView = UISwitch()
               switchView.isOn = settingsManager.notificationsEnabled
               switchView.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
               cell.accessoryView = switchView
               
               return cell
           }
       }
       
       @objc private func notificationSwitchChanged(_ sender: UISwitch) {
           // Immediately persist the new setting
              SettingsManager.shared.notificationsEnabled = sender.isOn
              
              // Provide visual feedback
              let feedback = UINotificationFeedbackGenerator()
              feedback.notificationOccurred(.success)
              
              print("Notifications \(sender.isOn ? "enabled" : "disabled")")
       }
       
       // MARK: - Table View Delegate
       
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           guard let section = Section(rawValue: indexPath.section), section == .theme else { return }
           
           tableView.deselectRow(at: indexPath, animated: true)
           let selectedTheme = themes[indexPath.row]
           settingsManager.currentTheme = selectedTheme.rawValue
           ThemeManager.shared.applyTheme()
           tableView.reloadSections(IndexSet(integer: Section.theme.rawValue), with: .none)
       }
       
       override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           guard let section = Section(rawValue: section) else { return nil }
           
           switch section {
           case .theme: return "Appearance"
           case .notifications: return "Notifications"
           }
       }
   }
