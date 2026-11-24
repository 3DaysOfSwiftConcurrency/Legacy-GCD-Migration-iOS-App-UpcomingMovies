//
//  CollapsibleCollectionHeaderViewTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 12/10/24.
//  Copyright © 2024 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies

final class CollapsibleCollectionHeaderViewTests: XCTestCase {

    private var headerView: CollapsibleCollectionHeaderView?

    override func setUpWithError() throws {
        try super.setUpWithError()
        let bundle = Bundle(for: CollapsibleCollectionHeaderView.self)
        headerView = bundle.loadNibNamed(CollapsibleCollectionHeaderView.dequeueIdentifier, owner: nil)?.first as? CollapsibleCollectionHeaderView
    }

    override func tearDownWithError() throws {
        headerView = nil
        try super.tearDownWithError()
    }

    func testTapGestureAddedOnAwakeFromNib() {
        // Assert
        XCTAssertEqual(headerView?.gestureRecognizers?.count, 1)
        XCTAssertNotNil(headerView?.gestureRecognizers?.first as? UITapGestureRecognizer)
    }

    func testTapGestureAction() {
        // Arrange
        let delegate = MockCollapsibleHeaderViewDelegate()
        headerView?.configure(with: MockCollapsibleHeaderViewModelProtocol())
        headerView?.delegate = delegate
        // Act
        headerView?.tapGestureAction()
        // Assert
        XCTAssertEqual(delegate.sectionToggledCallCount, 1)
    }

    func testTapGestureActionWithNoViewModel() {
        // Arrange
        let delegate = MockCollapsibleHeaderViewDelegate()
        headerView?.delegate = delegate
        // Act
        headerView?.tapGestureAction()
        // Assert
        XCTAssertEqual(delegate.sectionToggledCallCount, 0)
    }

    func testUpdateArrowImageView() throws {
        // Arrange
        let viewModel = MockCollapsibleHeaderViewModelProtocol()
        viewModel.arrowRotationValueResult = .pi / 2
        headerView?.configure(with: viewModel)
        // Act
        headerView?.updateArrowImageView(animated: true)
        // Assert
        let rotation = try XCTUnwrap(headerView?.arrowImageView.layer.animation(forKey: "transform.rotation") as? CABasicAnimation)
        XCTAssertEqual(rotation.keyPath, "transform.rotation")
        XCTAssertEqual((rotation.toValue as? NSNumber)?.doubleValue, Double.pi / 2)
        XCTAssertEqual(rotation.duration, 0.3)
    }

    func testUpdateArrowImageViewWithoutAnimation() {
        // Arrange
        let viewModel = MockCollapsibleHeaderViewModelProtocol()
        viewModel.arrowRotationValueResult = .pi / 2
        headerView?.configure(with: viewModel)
        // Act
        headerView?.updateArrowImageView(animated: false)
        // Assert
        XCTAssertEqual(headerView?.arrowImageView.transform, CGAffineTransform(rotationAngle: .pi / 2))
    }

}
