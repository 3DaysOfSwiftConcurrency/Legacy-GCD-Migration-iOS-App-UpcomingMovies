//
//  NavigationHandler.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/16/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UIKit

final class NavigationHandler: NavigationHandlerProtocol {

    private let deepLinkHandler: DeepLinkHandlerProtocol
    private lazy var rootCoordinators: [RootCoordinator] = {
        let coordinators = MainTabBarBuilder.buildViewCoordinators()
        deepLinkHandler.register(rootCoordinators: coordinators)
        return coordinators
    }()

    private var initialTransitionCompleted: Bool = false
    private enum Destination { case link(URL), search }
    private var pending: [Destination] = []

    // MARK: - Initializers

    init(deepLinkHandler: DeepLinkHandlerProtocol) {
        self.deepLinkHandler = deepLinkHandler
    }

    // MARK: - NavigationHandlerProtocol

    func initialTransition(from window: UIWindow?) {
        guard let window, let mainTabBarController = window.rootViewController as? MainTabBarController else { return }
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [UIView.AnimationOptions.curveEaseOut,
                                    UIView.AnimationOptions.transitionCrossDissolve],
                          animations: {},
                          completion: { _ in
            mainTabBarController.install(self.rootCoordinators)
            mainTabBarController.setSelectedIndex(0)
            self.initialTransitionCompleted = true
            for destination in self.pending { self.open(destination, in: window) }
            self.pending.removeAll()
        })
    }

    func handleUrlOpeningNavigation(for url: URL?, and window: UIWindow?) {
        guard let url else { return }

        guard url.scheme == AppExtension.scheme, let host = url.host,
              DeepLinkDestination(rawValue: host) != nil else { return }
        open(.link(url), in: window)
    }

    private func open(_ destination: Destination, in window: UIWindow?) {
        guard initialTransitionCompleted, window?.rootViewController is MainTabBarController else {
            pending.append(destination)
            return
        }
        switch destination {
        case .link(let url): deepLinkHandler.handleDeepLinkUrl(url, in: window)
        case .search: changeTabBarToSelectedIndex(RootCoordinatorIdentifier.searchMovies, from: window)
        }
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem, and window: UIWindow?) {
        guard let shorcut = AppShortcutItem(rawValue: shortcutItem.type) else { return }
        switch shorcut {
        case .searchMovies:
            open(.search, in: window)
        }
    }

    // MARK: - Private

    private func changeTabBarToSelectedIndex(_ rootIdentifier: String, from window: UIWindow?) {
        guard let tabBarController = window?.rootViewController as? MainTabBarController else {
            return
        }
        tabBarController.setSelectedIndex(index(for: rootIdentifier))
    }

    private func index(for rootIdentifier: String) -> Int {
        let coordinatorIdentifiers = rootCoordinators.map { $0.rootIdentifier }
        guard let indexToSelect = coordinatorIdentifiers.firstIndex(of: rootIdentifier) else {
            fatalError()
        }

        return indexToSelect
    }

}
