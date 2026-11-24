import XCTest
@testable import UpcomingMovies

@MainActor
final class RecentlyVisitedMoviesCellViewModelTests: XCTestCase {
    func testPreservesVisitOrder() {
        let cells = ["b", "a"].map { VisitedMovieCellViewModel(movieVisit: MockMovieVisitProtocol(posterPath: $0)) }
        let model = RecentlyVisitedMoviesCellViewModel(visitedMovieCells: cells)
        XCTAssertEqual(model.visitedMovieCells.map { $0.posterURL?.relativeString }, ["b", "a"])
    }
}
