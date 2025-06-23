//
//  SettingsVC.swift
//  MyBooks
//
//  Created by PeopleLink on 23/06/25.
//
import UIKit

class SettingsViewController: UITableViewController {
    
    private let themes = ThemeManager.Theme.allCases
    private let themeManager = ThemeManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "Appearance Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "themeCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)
        let theme = themes[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = theme.rawValue
        content.textProperties.font = .systemFont(ofSize: 17, weight: .medium)
        cell.contentConfiguration = content
        
        cell.accessoryType = themeManager.currentTheme == theme ? .checkmark : .none
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.tintColor = .systemBlue
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTheme = themes[indexPath.row]
        themeManager.currentTheme = selectedTheme
        
        // Update checkmarks
        tableView.visibleCells.forEach { cell in
            if let indexPath = tableView.indexPath(for: cell) {
                cell.accessoryType = indexPath.row == selectedTheme.rawValue.hashValue ? .checkmark : .none
            }
        }
        
        // Animate changes
        UIView.transition(
            with: tableView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { tableView.reloadData() }
        )
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let label = UILabel()
        label.text = "SELECT THEME"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        header.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
        ])
        return header
    }
}
