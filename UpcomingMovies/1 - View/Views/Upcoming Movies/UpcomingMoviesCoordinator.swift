//
//  UpcomingMoviesCoordinator.swift
//  UpcomingMovies
//
//  Created by Alonso on 6/13/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UIKit

struct UpcomingMoviesNavigationConfiguration {

    let selectedFrame: CGRect
    let imageToTransition: UIImage?
    let transitionOffset: CGFloat

}

final class UpcomingMoviesCoordinator: BaseCoordinator, UpcomingMoviesCoordinatorProtocol, RootCoordinator, MovieDetailCoordinable {

    private var navigationDelegate: UpcomingMoviesNavigationDelegate?

    init(navigationController: UINavigationController,
         navigationDelegate: UpcomingMoviesNavigationDelegate?) {
        self.navigationDelegate = navigationDelegate
        super.init(navigationController: navigationController)
    }

    // MARK: - Coordinator

    var rootIdentifier: String {
        RootCoordinatorIdentifier.upcomingMovies
    }

    override func build() -> UpcomingMoviesViewController {
        let viewController = UpcomingMoviesViewController.instantiate()

        viewController.viewModel = DIContainer.shared.resolve()
        viewController.layoutProvider = DIContainer.shared.resolve()
        viewController.coordinator = self

        return viewController
    }

    func showMovieDetail(for movie: MovieProtocol, with navigationConfiguration: UpcomingMoviesNavigationConfiguration?) {
        if let navigationConfiguration = navigationConfiguration {
            configureNavigationDelegate(with: navigationConfiguration)
        }

        showMovieDetail(for: movie)
    }

    // MARK: - Navigation Configuration

    override func setupNavigationControllerDelegate() {
        // We only configure the delegate if it is needed.
        guard navigationController.delegate == nil, let navigationDelegate else { return }
        navigationDelegate.parentCoordinator = self

        navigationController.delegate = navigationDelegate
    }

    private func configureNavigationDelegate(with navigationConfiguration: UpcomingMoviesNavigationConfiguration) {
        setupNavigationControllerDelegate()

        navigationDelegate?.configure(selectedFrame: navigationConfiguration.selectedFrame,
                                      with: navigationConfiguration.imageToTransition)
        navigationDelegate?.updateOffset(navigationConfiguration.transitionOffset)
    }

}
