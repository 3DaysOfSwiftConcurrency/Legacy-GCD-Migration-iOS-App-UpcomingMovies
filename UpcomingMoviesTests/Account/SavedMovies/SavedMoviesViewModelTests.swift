//
//  SavedMoviesViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 7/24/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
@testable import UpcomingMoviesDomain

@MainActor
final class SavedMoviesViewModelTests: XCTestCase {

    private var savedMoviesFeature: SavedMoviesFeature!
    private var accountUseCase: AccountUseCaseProtocolMock!
    private var viewModelToTest: SavedMoviesViewModelProtocol!

    override func setUp() {
        super.setUp()
        accountUseCase = AccountUseCaseProtocolMock()
        savedMoviesFeature = SavedMoviesFeature(accountUseCase: accountUseCase)
        viewModelToTest = SavedMoviesViewModel(savedMoviesFeature: savedMoviesFeature, collection: .favorites)
    }

    override func tearDown() {
        savedMoviesFeature = nil
        accountUseCase = nil
        viewModelToTest = nil
        super.tearDown()
    }

    func testSavedMoviesTitle() {
        // Arrange
        viewModelToTest.displayTitle = "Test title"
        // Act
        let title = viewModelToTest.displayTitle
        // Assert
        XCTAssertEqual(title, "Test title")
    }

    func testEmptyMovieResultsTitle() {
        // Act
        let title = viewModelToTest.emptyMovieResultsTitle
        // Assert
        XCTAssertEqual(title, "There are no movies to show right now.")
    }

    func testGetCollectionListPopulated() async {
        let movies = [Movie.with(id: 1), Movie.with(id: 2)]
        let expectedMovies = movies.map(MovieModel.init)

        await loadFavorites(.success(movies))
        XCTAssertEqual(viewModelToTest.viewState.value, .paging(expectedMovies, next: 2))

        await loadFavorites(.success([]))
        XCTAssertEqual(viewModelToTest.viewState.value, .populated(expectedMovies))
        XCTAssertEqual(viewModelToTest.viewState.value.currentEntities.map(\.id), movies.map(\.id))
    }

    func testGetCollectionListPaging() async {
        let movies = [Movie.with(id: 1), Movie.with(id: 2)]
        await loadFavorites(.success(movies))
        XCTAssertEqual(viewModelToTest.viewState.value, .paging(movies.map(MovieModel.init), next: 2))
    }

    func testGetCollectionListEmpty() async {
        await loadFavorites(.success([]))
        XCTAssertEqual(viewModelToTest.viewState.value, .empty)
    }

    func testGetCollectionListError() async {
        let error = TestError()
        await loadFavorites(.failure(error))
        XCTAssertEqual(viewModelToTest.viewState.value, .error(error))
    }

    func testMovieCellsCount() async {
        let movies = [Movie.with(id: 1), Movie.with(id: 2)]
        await loadFavorites(.success(movies))
        XCTAssertEqual(viewModelToTest.movieCells.count, movies.count)
    }

    func testMovieCellsZeroCount() async {
        await loadFavorites(.success([]))
        XCTAssertEqual(viewModelToTest.movieCells.count, .zero)
    }

    func testMovieIndex() async {
        let movies = [Movie.with(id: 1), Movie.with(id: 2)]
        await loadFavorites(.success(movies))
        guard viewModelToTest.movieCells.count == movies.count else {
            return XCTFail("Expected both movies before checking their indices")
        }
        for index in movies.indices {
            XCTAssertEqual(viewModelToTest.movie(at: index).id, movies[index].id)
        }
    }

    private func loadFavorites(_ result: Result<[Movie], Error>) async {
        let didPublish = expectation(description: "Saved movie state published")
        viewModelToTest.viewState.bind { _ in didPublish.fulfill() }
        accountUseCase.getFavoriteListResult = result
        viewModelToTest.getCollectionList()
        await fulfillment(of: [didPublish], timeout: 1.0)
    }

}
