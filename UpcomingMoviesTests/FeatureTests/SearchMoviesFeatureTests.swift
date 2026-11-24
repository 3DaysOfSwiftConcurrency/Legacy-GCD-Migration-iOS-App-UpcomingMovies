import XCTest
@testable import UpcomingMovies

@MainActor
final class SearchMoviesFeatureTests: XCTestCase {
    func testEverySaveGetsItsOwnOrderedOutcome() async throws {
        let dependencies = SearchMoviesFeatureTestDependencies()
        let feature = dependencies.makeFeature(observeHistory: false)
        let started = expectation(description: "First save suspended")
        var release: ((Result<Void, Error>) -> Void)?
        var writes: [String] = []
        dependencies.movieSearchUseCase.onSave = { text, completion in
            writes.append(text)
            if writes.count == 1 {
                release = completion
                started.fulfill()
            } else {
                completion(.success(()))
            }
        }

        let first = feature.recordSearchText("Alien")
        await fulfillment(of: [started], timeout: 2)
        let second = feature.recordSearchText("Alien")
        let third = feature.recordSearchText("Arrival")
        XCTAssertEqual(writes, ["Alien"])
        release?(.failure(TestError()))
        let firstResult = await first.value
        XCTAssertThrowsError(try firstResult.get())
        try await second.value.get()
        try await third.value.get()
        XCTAssertEqual(writes, ["Alien", "Alien", "Arrival"])
    }
}
