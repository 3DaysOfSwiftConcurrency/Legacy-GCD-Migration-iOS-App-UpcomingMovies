//
//  UpcomingMoviesViewModelTests.swift
//  UpcomingMoviesTests
//
//  Created by Alonso on 11/5/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import XCTest
@testable import UpcomingMovies
import UpcomingMoviesDomain

@MainActor
final class UpcomingMoviesViewModelTests: XCTestCase {

    typealias MoviesViewState = SimpleViewState<MovieProtocol>

    private var mockMoviesLoader: MockUpcomingMoviesLoader!
    private var mockFactory = MockUpcomingMoviesFactory()
    private var mockUserPreferencesHandler = MockUserPreferencesHandler()
    private var viewModelToTest: UpcomingMoviesViewModelProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMoviesLoader = MockUpcomingMoviesLoader()
        let upcomingMoviesFeature = UpcomingMoviesFeature(loadUpcomingMovies: { page, completion in
            self.mockMoviesLoader.loadMovies(page: page, completion: completion)
        }, makeMoviePresentationModel: { movie in
            MockMovieProtocol(id: movie.id)
        })
        viewModelToTest = UpcomingMoviesViewModel(upcomingMoviesFeature: upcomingMoviesFeature,
                                                  factory: mockFactory,
                                                  userPreferencesHandler: mockUserPreferencesHandler)
    }

    override func tearDownWithError() throws {
        mockMoviesLoader = nil
        viewModelToTest = nil
        try super.tearDownWithError()
    }

    func testGetMoviesEmpty() async {
        // Arrange
        let moviesToTest: [Movie] = []
        // Act
        mockMoviesLoader.upcomingMovies = Result.success(moviesToTest)
        await viewModelToTest.getMovies().value
        // Assert
        XCTAssertEqual(viewModelToTest.viewState.value, .empty)
    }

    func testGetMoviesPopulated() async {
        // Arrange
        let receivedMovies = [makeMovie(id: 1), makeMovie(id: 2)]
        let expectedMovies: [MovieProtocol] = [MockMovieProtocol(id: 1), MockMovieProtocol(id: 2)]
        var statesToReceive: [MoviesViewState] = [.paging(expectedMovies, next: 2), .populated(expectedMovies)]
        // Act
        mockMoviesLoader.upcomingMovies = Result.success(receivedMovies)
        await viewModelToTest.getMovies().value
        XCTAssertEqual(viewModelToTest.viewState.value, statesToReceive.removeFirst())
        mockMoviesLoader.upcomingMovies = Result.success([])
        await viewModelToTest.getMovies().value
        // Assert
        XCTAssertEqual(viewModelToTest.viewState.value, statesToReceive.removeFirst())
    }

    func testGetMoviesPaging() async {
        // Arrange
        let receivedMovies = [makeMovie(id: 1), makeMovie(id: 2)]
        let expectedMovies: [MovieProtocol] = [MockMovieProtocol(id: 1), MockMovieProtocol(id: 2)]
        // Act
        mockMoviesLoader.upcomingMovies = Result.success(receivedMovies)
        await viewModelToTest.getMovies().value
        // Assert
        XCTAssertEqual(viewModelToTest.viewState.value, .paging(expectedMovies, next: 2))
    }

    func testPrefetchAppendsInOrderAndRefreshReplacesTheListFromPageOne() async {
        mockMoviesLoader.upcomingMovies = .success([makeMovie(id: 7)])
        let initialLoad = viewModelToTest.getMovies()
        XCTAssertTrue(viewModelToTest.startLoading.value)
        await initialLoad.value
        XCTAssertFalse(viewModelToTest.startLoading.value)
        XCTAssertTrue(viewModelToTest.needsPrefetch)

        mockMoviesLoader.upcomingMovies = .success([makeMovie(id: 3)])
        let prefetch = viewModelToTest.getMovies()
        XCTAssertFalse(viewModelToTest.startLoading.value)
        await prefetch.value
        XCTAssertEqual(viewModelToTest.viewState.value.currentEntities.map(\.id), [7, 3])

        mockMoviesLoader.upcomingMovies = .success([makeMovie(id: 9)])
        let refresh = viewModelToTest.refreshMovies()
        XCTAssertFalse(viewModelToTest.startLoading.value)
        await refresh.value
        XCTAssertEqual(mockMoviesLoader.requestedPages, [1, 2, 1])
        XCTAssertEqual(viewModelToTest.viewState.value.currentEntities.map(\.id), [9])
        XCTAssertEqual(viewModelToTest.viewState.value.currentPage, 2)
    }

    func testLoadErrorCanBeRetriedFromPageOne() async {
        // Arrange
        let errorToTest = TestError()
        // Act
        mockMoviesLoader.upcomingMovies = Result.failure(errorToTest)
        await viewModelToTest.getMovies().value
        // Assert
        XCTAssertEqual(viewModelToTest.viewState.value, .error(errorToTest))
        XCTAssertFalse(viewModelToTest.startLoading.value)
        XCTAssertFalse(viewModelToTest.needsPrefetch)

        mockMoviesLoader.upcomingMovies = .success([makeMovie(id: 4)])
        await viewModelToTest.refreshMovies().value
        XCTAssertEqual(mockMoviesLoader.requestedPages, [1, 1])
        XCTAssertEqual(viewModelToTest.viewState.value.currentEntities.map(\.id), [4])
    }

    func testGetMoviesReusesTheInFlightLoadForTheSamePage() async {
        // Arrange
        mockMoviesLoader.upcomingMovies = .success([makeMovie(id: 1)])

        // Act
        let firstLoadTask = viewModelToTest.getMovies()
        let secondLoadTask = viewModelToTest.getMovies()
        await firstLoadTask.value
        await secondLoadTask.value

        // Assert
        XCTAssertEqual(mockMoviesLoader.requestedPages, [1])
    }

    func testUpcomingMovieCellPosterURL() {
        // Arrange
        let cellViewModel = UpcomingMovieCellViewModel(MockMovieProtocol(posterURL: URL(string: "https://image.tmdb.org/t/p/w185/poster.jpg")))
        // Act
        let posterURL = cellViewModel.posterURL
        // Assert
        XCTAssertEqual(posterURL, URL(string: "https://image.tmdb.org/t/p/w185/poster.jpg"))
    }

    func testUpcomingMovieCellBackdropURL() {
        // Arrange
        let cellViewModel = UpcomingMovieCellViewModel(MockMovieProtocol(backdropURL: URL(string: "https://image.tmdb.org/t/p/w500/backdrop.jpg")))
        // Act
        let backdropURL = cellViewModel.backdropURL
        // Assert
        XCTAssertEqual(backdropURL, URL(string: "https://image.tmdb.org/t/p/w500/backdrop.jpg"))
    }

    private func makeMovie(id: Int) -> Movie {
        Movie(id: id,
              title: "Movie \(id)",
              genreIds: nil,
              overview: "Overview",
              posterPath: nil,
              backdropPath: nil,
              releaseDate: nil,
              voteAverage: nil)
    }

}
