import XCTest
@testable import UpcomingMovies

@MainActor
final class VisitedMovieCellViewModelTests: XCTestCase {
    func testBuildsPosterURLFromVisit() {
        let path = "https://example.invalid/poster.jpg"
        let model = VisitedMovieCellViewModel(movieVisit: MockMovieVisitProtocol(posterPath: path))
        XCTAssertEqual(model.posterURL?.absoluteString, path)
    }
}
