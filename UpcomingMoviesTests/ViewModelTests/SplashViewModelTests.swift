import XCTest
import UpcomingMoviesDomain
@testable import UpcomingMovies

final class SplashViewModelTests: XCTestCase {

    @MainActor
    func testNavigationIsReleasedWhileGenreRestoreIsStillPending() async {
        let started = expectation(description: "Genre request is pending")
        let navigable = expectation(description: "Splash permits navigation")
        let interactor = PendingGenres(started: started)
        let model = SplashViewModel(makeInteractor: { interactor }, genreHandler: GenreHandler(),
                                    configurationHandler: ConfigurationHandler())
        model.initialDownloadsEnded.bind({ navigable.fulfill() })
        model.startInitialDownloads()
        await fulfillment(of: [started, navigable], timeout: 2)
        interactor.pending?.resume(returning: nil)
    }

}

private final class PendingGenres: SplashInteractorProtocol {
    let started: XCTestExpectation
    var pending: CheckedContinuation<[Genre]?, Never>?

    init(started: XCTestExpectation) { self.started = started }
    func appConfiguration() async -> Configuration? { nil }
    func allGenres() async -> [Genre]? {
        await withCheckedContinuation { continuation in
            pending = continuation
            started.fulfill()
        }
    }
}
