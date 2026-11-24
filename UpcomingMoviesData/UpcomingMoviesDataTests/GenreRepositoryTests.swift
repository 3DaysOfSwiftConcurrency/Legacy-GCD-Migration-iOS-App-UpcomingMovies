import XCTest
import UpcomingMoviesDomain
@testable import UpcomingMoviesData

final class GenreRepositoryTests: XCTestCase {
    @MainActor
    func testFreshGenresWinWithoutWaitingForRestoreOrSave() async {
        let restoreStarted = expectation(description: "Restore started")
        let refreshStarted = expectation(description: "Refresh started")
        let disk = GenreDisk { restoreStarted.fulfill() }
        let server = GenreServer { refreshStarted.fulfill() }
        let repository = GenreRepository(localDataSource: disk, remoteDataSource: server)
        let fresh = [Genre(id: 1, name: "Action")]
        let refreshed = expectation(description: "Fresh response before cache write")

        repository.fetchAll(completion: { result in
            XCTAssertEqual(try? result.get(), fresh)
            XCTAssertTrue(disk.pendingWrites.isEmpty)
            refreshed.fulfill()
        }, forceRefresh: true)
        await fulfillment(of: [restoreStarted, refreshStarted], timeout: 2)
        server.reply?(.success(fresh))
        await fulfillment(of: [refreshed], timeout: 2)
        disk.restore?([Genre(id: 1, name: "Old")])

        let failed = expectation(description: "Refresh failed")
        server.started = { server.reply?(.failure(URLError(.notConnectedToInternet))) }
        repository.fetchAll(completion: { result in
            if case .success = result { XCTFail("Expected a refresh error") }
            failed.fulfill()
        }, forceRefresh: true)
        await fulfillment(of: [failed], timeout: 2)

        let retained = expectation(description: "Last successful response retained")
        repository.fetchAll(completion: { result in
            XCTAssertEqual(try? result.get(), fresh)
            retained.fulfill()
        }, forceRefresh: false)
        await fulfillment(of: [retained], timeout: 2)
        XCTAssertEqual(disk.pendingWrites, [fresh])
        server.started = {}
    }
}

private final class GenreDisk: GenreLocalDataSourceProtocol {
    let started: () -> Void
    var restore: (([Genre]) -> Void)?
    var pendingWrites: [[Genre]] = []
    var didUpdateGenre: (() -> Void)?

    init(started: @escaping () -> Void) { self.started = started }

    func restoreGenres(completion: @escaping ([Genre]) -> Void) {
        restore = completion
        started()
    }

    func saveGenres(_ genres: [Genre]) { pendingWrites.append(genres) }
    func find(with id: Int) -> Genre? { nil }
}

private final class GenreServer: GenreRemoteDataSourceProtocol {
    var started: () -> Void
    var reply: ((Result<[Genre], Error>) -> Void)?

    init(started: @escaping () -> Void) { self.started = started }

    func getAllGenres(completion: @escaping (Result<[Genre], Error>) -> Void) {
        reply = completion
        started()
    }
}
