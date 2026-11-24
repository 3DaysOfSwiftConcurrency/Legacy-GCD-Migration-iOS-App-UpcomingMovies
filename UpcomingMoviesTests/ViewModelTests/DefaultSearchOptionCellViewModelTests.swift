import XCTest
@testable import UpcomingMovies

@MainActor
final class DefaultSearchOptionCellViewModelTests: XCTestCase {
    func testPresentsTopRatedCopy() {
        let model = DefaultSearchOptionCellViewModel(defaultSearchOption: .topRated)
        XCTAssertEqual(model.title, LocalizedStrings.topRatedMoviesTitle())
        XCTAssertEqual(model.subtitle, LocalizedStrings.topRatedMoviesSubtitle())
    }
}
