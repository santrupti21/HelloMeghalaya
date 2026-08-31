//
//  MainTabBarController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 20/08/26.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        setupTabBarAppearance()
    }
    
    private func setupTabs() {
        let homeViewController = ViewController()
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        homeNavigationController.setNavigationBarHidden(true, animated: false) // Hiding the nav bar
        
        let trailerViewController = UIViewController()
        let downloadsViewController = UIViewController()
        let moreViewController = UIViewController()
        
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        trailerViewController.tabBarItem = UITabBarItem(title: "Trailers", image: UIImage(systemName: "play.rectangle"), selectedImage: UIImage(systemName: "play.rectangle.fill"))
        
        downloadsViewController.tabBarItem = UITabBarItem(title: "Downloads", image: UIImage(systemName: "arrow.down.circle"), selectedImage: UIImage(systemName: "arrow.down.circle.fill"))
        
        moreViewController.tabBarItem = UITabBarItem(title: "More", image: UIImage(systemName: "square.grid.2x2"), selectedImage: UIImage(systemName: "square.grid.2x2.fill"))
        
        viewControllers = [homeNavigationController, trailerViewController, downloadsViewController, moreViewController]
    }
    
    private func setupTabBarAppearance() {
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        tabBar.tintColor = .systemGreen
        tabBar.unselectedItemTintColor = .gray
    }
    
}
