import XCTest
@testable import UpcomingMovies

@MainActor
final class ProfileSelectableOptionCellViewModelTests: XCTestCase {
    func testDisplaysWatchlistOption() {
        XCTAssertEqual(ProfileSelectableOptionCellViewModel(ProfileOption.watchlist).title, LocalizedStrings.watchlistCollectionOption())
    }
}
