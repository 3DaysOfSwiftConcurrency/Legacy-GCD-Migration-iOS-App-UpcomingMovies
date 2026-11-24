//
//  SplashBuilderTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 25/03/24.
//  Copyright © 2024 Alonso. All rights reserved.
//

import XCTest
import UpcomingMoviesDomain
@testable import UpcomingMovies

final class SplashBuilderTests: XCTestCase {

    @MainActor
    func testColdLinksAreDeliveredToTheirReceivingWindow() async throws {
        let firstURL = try XCTUnwrap(AppExtension.url(for: .searchMovies))
        let secondURL = try XCTUnwrap(AppExtension.url(for: .upcomingMovies))
        let firstSpy = LinkSpy(opened: expectation(description: "First window opens"))
        let secondSpy = LinkSpy(opened: expectation(description: "Second window opens"))
        let first = NavigationHandler(deepLinkHandler: firstSpy)
        let second = NavigationHandler(deepLinkHandler: secondSpy)
        let windows = [UIWindow(), UIWindow()]
        let roots = [MainTabBarController(), MainTabBarController()]
        for (window, root) in zip(windows, roots) { window.rootViewController = root }

        first.handleUrlOpeningNavigation(for: firstURL, and: nil)
        second.handleUrlOpeningNavigation(for: secondURL, and: nil)
        second.initialTransition(from: windows[1])
        await fulfillment(of: [secondSpy.opened], timeout: 2)
        XCTAssertTrue(firstSpy.urls.isEmpty)
        first.initialTransition(from: windows[0])
        await fulfillment(of: [firstSpy.opened], timeout: 2)
        XCTAssertEqual(firstSpy.urls, [firstURL])
        XCTAssertEqual(secondSpy.urls, [secondURL])
        XCTAssertTrue(firstSpy.window === windows[0])
        XCTAssertTrue(secondSpy.window === windows[1])
        XCTAssertTrue(windows[0].rootViewController === roots[0])
        XCTAssertTrue(windows[1].rootViewController === roots[1])
    }

    func testBuildViewController() {
        // Act
        let tabBarController = SplashBuilder.buildViewController() as? UITabBarController
        let navigationController = tabBarController?.viewControllers?.first as? UINavigationController
        let splashViewController = navigationController?.viewControllers.first as? SplashViewController
        // Assert
        XCTAssertEqual(tabBarController?.viewControllers?.count, 1)
        XCTAssertEqual(navigationController?.viewControllers.count, 1)

        XCTAssertNotNil(splashViewController?.viewModel)
        XCTAssertNotNil(splashViewController?.navigationHandler)
    }

}

private final class LinkSpy: DeepLinkHandlerProtocol {
    let opened: XCTestExpectation
    var urls: [URL] = []
    weak var window: UIWindow?

    init(opened: XCTestExpectation) { self.opened = opened }
    func register(rootCoordinators: [RootCoordinator]) {}
    func handleDeepLinkUrl(_ url: URL, in window: UIWindow?) {
        urls.append(url)
        self.window = window
        opened.fulfill()
    }
}
