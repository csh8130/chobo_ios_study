//
//  MainTabController.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/04/03.
//

import UIKit

class MainTabController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    // MARK: - Helpers
    
    func configureViewController() {
        view.backgroundColor = .white

        let feed = FeedController()
        let search = SearchController()
        let imageSelector = ImageSelectorController()
        let notifications = NotificationController()
        let profile = ProfileController()
        
        viewControllers = [feed, search, imageSelector, notifications, profile]
    }
}
