//
//  AccountViewController.swift
//  UpcomingMovies
//
//  Created by Alonso on 3/20/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UIKit

final class AccountViewController: UIViewController, Storyboarded {

    static var storyboardName: String = "Account"

    var viewModel: AccountViewModelProtocol?
    weak var coordinator: AccountCoordinatorProtocol?

    private var accountLoad: Task<Void, Never>?
    private var retryFooter: UIView?

    deinit { accountLoad?.cancel() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = view.tintColor
        setDefaultAppearanceNavigationBar(with: ColorPalette.navigationBarBackgroundColor)
    }

    // MARK: - Private

    private func setupUI() {
        title = viewModel?.title
        setupContainerView()
        setupNavigationBar()
    }

    private func setupContainerView() {
        guard let viewModel else { return }
        accountLoad?.cancel()
        accountLoad = Task { [weak self] in
            do {
                let user = try await viewModel.loadCurrentUser()
                guard !Task.isCancelled, let self else { return }
                retryFooter?.removeFromSuperview()
                if let user {
                    coordinator?.embedProfileViewController(on: self, for: user)
                    coordinator?.removeSignInViewController(from: self)
                } else {
                    showSignInView()
                }
            } catch {
                guard !Task.isCancelled, let self else { return }
                retryFooter?.removeFromSuperview()
                let footer = FooterView.retryFooter(for: error) { [weak self] in self?.setupContainerView() }
                view.addSubview(footer)
                footer.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                footer.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
                retryFooter = footer
            }
        }
    }

    private func setupNavigationBar() {
        navigationItem.title = viewModel?.navigationItemTitle
    }

    private func showSignInView(withAnimatedNavigationBar animated: Bool = false) {
        coordinator?.embedSignInViewController(on: self)
        coordinator?.removeProfileViewController(from: self)
    }

    private func showProfileView(withAnimatedNavigationBar animated: Bool = false) {
        guard let viewModel = viewModel, let user = viewModel.currentUser() else { return }
        coordinator?.embedProfileViewController(on: self, for: user)
        coordinator?.removeSignInViewController(from: self)
    }

}

// MARK: - SignInViewControllerDelegate

extension AccountViewController: SignInViewControllerDelegate {

    func didUpdateAuthenticationState(_ state: AuthenticationState) {
        switch state {
        case .justSignedIn: showProfileView(withAnimatedNavigationBar: true)
        case .justSignedOut: showSignInView(withAnimatedNavigationBar: true)
        case .currentlySignedIn: showProfileView()
        case .currentlySignedOut: showSignInView()
        }
    }

}

// MARK: - ProfileViewControllerDelegate

extension AccountViewController: ProfileViewControllerDelegate {

    func profileViewController(didTapProfileOption option: ProfileOptionProtocol) {
        coordinator?.showProfileOption(option)
    }

}
