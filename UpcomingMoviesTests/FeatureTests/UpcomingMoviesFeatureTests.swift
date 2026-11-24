//
//  UpcomingMoviesFeatureTests.swift
//  UpcomingMoviesTests
//

import XCTest
@testable import UpcomingMovies
import UpcomingMoviesDomain

@MainActor
final class UpcomingMoviesFeatureTests: XCTestCase {

    func testEquivalentPageLoadsShareOneExecution() async throws {
        let started = expectation(description: "Page is pending")
        var finish: ((Result<[Movie], Error>) -> Void)?
        var calls = 0
        let feature = UpcomingMoviesFeature(preferences: MockUserPreferencesHandler(), loadUpcomingMovies: { _, completion in
            calls += 1
            finish = completion
            started.fulfill()
        }, makeMoviePresentationModel: { MockMovieProtocol(id: $0.id) })

        let first = Task { try await feature.loadMovies(page: 1) }
        await fulfillment(of: [started], timeout: 2)
        let expected = makeMovie(id: 1)
        Task { @MainActor in finish?(.success([expected])) }
        let secondPage = try await feature.loadMovies(page: 1)
        let firstPage = try await first.value
        XCTAssertEqual(firstPage.map(\.id), [1])
        XCTAssertEqual(secondPage.map(\.id), [1])
        XCTAssertEqual(calls, 1)
    }

    func testCancelledWaiterDoesNotCancelSharedPage() async throws {
        let started = expectation(description: "shared page started")
        var finish: ((Result<[Movie], Error>) -> Void)?
        var calls = 0
        let feature = UpcomingMoviesFeature(preferences: MockUserPreferencesHandler(), loadUpcomingMovies: { _, completion in
            calls += 1
            finish = completion
            started.fulfill()
        }, makeMoviePresentationModel: { MockMovieProtocol(id: $0.id) })
        let waiter = Task { try await feature.loadMovies(page: 1) }
        await fulfillment(of: [started], timeout: 2)
        waiter.cancel()
        // Schedule delivery on this actor after the next caller joins the page.
        Task { @MainActor in finish?(.success([makeMovie(id: 4)])) }
        let movies = try await feature.loadMovies(page: 1)
        XCTAssertEqual(movies.map(\.id), [4])
        XCTAssertEqual(calls, 1)
        if case .failure(let error) = await waiter.result {
            XCTAssertTrue(error is CancellationError)
        } else {
            XCTFail("Cancelled waiter received a result")
        }
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
