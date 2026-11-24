//
//  SplashBuilder.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/18/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UIKit

final class SplashBuilder {

    static func buildViewController(navigationHandler: NavigationHandlerProtocol? = nil) -> UIViewController {
        let viewController = SplashViewController.instantiate()
        viewController.viewModel = DIContainer.shared.resolve()
        viewController.navigationHandler = navigationHandler ?? DIContainer.shared.resolve()

        let navigationController = UINavigationController(rootViewController: viewController)

        let tabBarController = MainTabBarController()
        tabBarController.viewControllers = [navigationController]

        return tabBarController
    }

}
