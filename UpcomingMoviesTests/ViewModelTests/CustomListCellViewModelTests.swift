import XCTest
@testable import UpcomingMovies

@MainActor
final class CustomListCellViewModelTests: XCTestCase {
    func testPresentsNameAndMovieCount() {
        let model = CustomListCellViewModel(MockListProtocol(name: "Classics", movieCount: 3))
        XCTAssertEqual(model.name, "Classics")
        XCTAssertEqual(model.movieCount, 3)
    }
}
