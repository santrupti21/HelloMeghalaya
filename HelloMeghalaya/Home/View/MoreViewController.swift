//
//  MoreViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 03/09/26.
//

import UIKit

final class MoreViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private let menuItems = [  ("Login/Register", "rectangle.portrait.and.arrow.right"),
        ("Content Language", "character.book.closed"),
        ("Notifications", "bell"),
        ("App Settings", "slider.horizontal.3"),
        ("Help", "questionmark.circle")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        view.backgroundColor = .black
        
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(MoreTableViewCell.self, forCellReuseIdentifier: "MoreTableViewCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                            equalTo: view.safeAreaLayoutGuide.topAnchor
                        ),

                        tableView.leadingAnchor.constraint(
                            equalTo: view.leadingAnchor
                        ),

                        tableView.trailingAnchor.constraint(
                            equalTo: view.trailingAnchor
                        ),

                        tableView.bottomAnchor.constraint(
                            equalTo: view.bottomAnchor
                        )
        ])
    }

}
extension MoreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoreTableViewCell", for: indexPath) as? MoreTableViewCell else {
            return UITableViewCell()
        }
        let item = menuItems[indexPath.row]
        cell.configure(title: item.0, icon: item.1)
        
        return cell
    }

}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = menuItems[indexPath.row]
        
        if selectedItem.0 == "Login/Register" {
            let loginViewController = LoginViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            
            present(loginViewController, animated: true)
    
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
