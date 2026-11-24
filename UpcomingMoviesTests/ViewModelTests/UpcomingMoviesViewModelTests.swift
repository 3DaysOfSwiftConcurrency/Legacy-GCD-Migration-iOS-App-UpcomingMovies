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
        let upcomingMoviesFeature = UpcomingMoviesFeature(preferences: mockUserPreferencesHandler, loadUpcomingMovies: { page, completion in
            self.mockMoviesLoader.loadMovies(page: page, completion: completion)
        }, makeMoviePresentationModel: { movie in
            MockMovieProtocol(id: movie.id)
        })
        viewModelToTest = UpcomingMoviesViewModel(upcomingMoviesFeature: upcomingMoviesFeature,
                                                  factory: mockFactory)
    }

    override func tearDownWithError() throws {
        mockMoviesLoader = nil
        viewModelToTest = nil
        try super.tearDownWithError()
    }

    func testModeChangeReachesBothSceneViewModels() {
        let feature = UpcomingMoviesFeature(preferences: mockUserPreferencesHandler,
                                           loadUpcomingMovies: { _, _ in },
                                           makeMoviePresentationModel: { MockMovieProtocol(id: $0.id) })
        let first = UpcomingMoviesViewModel(upcomingMoviesFeature: feature, factory: mockFactory)
        let second = UpcomingMoviesViewModel(upcomingMoviesFeature: feature, factory: mockFactory)
        var received: [UpcomingMoviesPresentationMode] = []
        second.didUpdatePresentationMode.bind({ received.append($0) }, on: .immediate)

        mockUserPreferencesHandler.upcomingMoviesPresentationMode = .preview
        first.updatePresentationMode()
        first.updatePresentationMode()

        XCTAssertEqual(received, [.detail, .preview])
        XCTAssertEqual(second.currentPresentationMode, .preview)
    }

    func testToggleUsesStoredModeAndPersistsBothTransitions() {
        mockUserPreferencesHandler.upcomingMoviesPresentationMode = .detail
        XCTAssertEqual(viewModelToTest.currentPresentationMode, .detail)
        viewModelToTest.updatePresentationMode()
        XCTAssertEqual(mockUserPreferencesHandler.upcomingMoviesPresentationMode, .preview)
        viewModelToTest.updatePresentationMode()
        XCTAssertEqual(mockUserPreferencesHandler.upcomingMoviesPresentationMode, .detail)
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

    func testSupersededPrefetchCannotReplaceRefreshOrClearItsHandle() async {
        for obsoleteFails in [false, true] {
            for finishesFirst in [false, true] {
                let prefetchStarted = expectation(description: "page two started")
                let refreshStarted = expectation(description: "refresh started")
                var finishPrefetch: ((Result<[Movie], Error>) -> Void)?
                var finishRefresh: ((Result<[Movie], Error>) -> Void)?
                let initialMovie = makeMovie(id: 1)
                var initial = true
                let feature = UpcomingMoviesFeature(preferences: mockUserPreferencesHandler, loadUpcomingMovies: { page, finish in
                    if initial {
                        initial = false
                        finish(.success([initialMovie]))
                    } else if page == 2 {
                        finishPrefetch = finish
                        prefetchStarted.fulfill()
                    } else {
                        finishRefresh = finish
                        refreshStarted.fulfill()
                    }
                }, makeMoviePresentationModel: { MockMovieProtocol(id: $0.id) })
                let model = UpcomingMoviesViewModel(upcomingMoviesFeature: feature, factory: mockFactory)
                await model.getMovies().value
                let old = model.getMovies()
                await fulfillment(of: [prefetchStarted], timeout: 2)
                let refresh = model.refreshMovies()
                await fulfillment(of: [refreshStarted], timeout: 2)
                let obsolete: Result<[Movie], Error> = obsoleteFails ? .failure(TestError()) : .success([makeMovie(id: 2)])
                if finishesFirst {
                    finishPrefetch?(obsolete)
                    await old.value
                    XCTAssertEqual(model.refreshMovies(), refresh)
                    XCTAssertFalse(model.startLoading.value)
                    XCTAssertEqual(model.viewState.value.currentEntities.map(\.id), [1])
                }
                finishRefresh?(.success([makeMovie(id: 3)]))
                await refresh.value
                if !finishesFirst {
                    finishPrefetch?(obsolete)
                    await old.value
                }
                XCTAssertEqual(model.viewState.value.currentEntities.map(\.id), [3])
                XCTAssertFalse(model.startLoading.value)
            }
        }
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
