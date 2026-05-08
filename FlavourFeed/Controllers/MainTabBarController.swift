// MainTabBarController.swift
// FlavourFeed

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }

    private func setupTabs() {
        // Tab 1: Home Feed
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Tab 2: Browse/Search
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "Browse",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        // Tab 3: Favourites
        let favVC = FavouritesViewController()
        let favNav = UINavigationController(rootViewController: favVC)
        favNav.tabBarItem = UITabBarItem(
            title: "Saved",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        // Tab 4: Profile
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [homeNav, searchNav, favNav, profileNav]
    }

    private func styleTabBar() {
        let accent = UIColor(named: "AccentOrange") ?? UIColor.systemOrange
        tabBar.tintColor = accent
        tabBar.unselectedItemTintColor = .systemGray3

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
