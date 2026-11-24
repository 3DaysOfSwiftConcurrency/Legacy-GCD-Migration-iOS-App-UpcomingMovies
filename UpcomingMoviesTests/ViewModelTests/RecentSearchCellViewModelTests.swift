import XCTest
@testable import UpcomingMovies

@MainActor
final class RecentSearchCellViewModelTests: XCTestCase {
    func testPreservesOriginalQueryForDisplay() {
        XCTAssertEqual(RecentSearchCellViewModel(searchText: "Amélie").searchText, "Amélie")
    }
}
